//
//  CustomImagePickerController.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "CustomImagePickerController.h"
#import "CustomImageManager.h"
#import "CameraCollectionViewCell.h"
#import "CustomAssetModel.h"
#import "PhotoCollectionViewCell.h"
#import "UIButton+Cat.h"

typedef enum : NSUInteger {
    CellTypeCamera = 0,
    CellTypeCommon
} CellType;

@interface CustomImagePickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,PhotoCollectionViewCellDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSMutableArray *photos;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *originalPhotoButton;
@property (weak, nonatomic) IBOutlet UILabel *originalPhotoLable;
@property (weak, nonatomic) IBOutlet UIImageView *numberImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLable;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation CustomImagePickerController

#pragma mark - PhotoCollectionViewCellDelegate

- (void)didSelectPhoto:(PhotoCollectionViewCell*)cell isSelect:(BOOL)isSelect{
    if (isSelect) {
        [self cancleSelected:cell];
    } else {
        [self addSelected:cell];
    }
    [PhotoCollectionViewCell showOscillatoryAnimationWithLayer:self.numberImageView.layer type:TZOscillatoryAnimationToSmaller];
}

-(void)cancleSelected:(PhotoCollectionViewCell*)cell{
    // 取消打勾
    cell.selectPhotoButton.selected = NO;
    cell.model.isSelected = NO;
    NSArray *selectedModels = [NSArray arrayWithArray:[CustomImageManager share].selectedModels];
    for (CustomAssetModel *model_item in selectedModels) {
        PHAsset *itemAsset =  model_item.asset;
        if ([cell.model.asset.localIdentifier isEqualToString:itemAsset.localIdentifier]) {
            [[CustomImageManager share].selectedModels removeObject:model_item];
        }
    }
    [self setupButtons];
}

-(void)addSelected:(PhotoCollectionViewCell*)cell{
    // 新增打勾
    if ([CustomImageManager share].selectedModels.count < 3) {
        cell.selectPhotoButton.selected = YES;
        cell.model.isSelected = YES;
        [[CustomImageManager share].selectedModels addObject:cell.model];
        [self setupButtons];
    } else {
        NSLog(@"最多只能選擇三張");
    }
}

#pragma mark - private instance method

#pragma mark * setup

-(void)setupInitValue{
    self.isSelectOriginalPhoto = YES;
}

-(void)setupNavigationBar{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.model.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
}

-(void)setupPhotoFetch{
    //獲得單一相本所有照片資訊
    [[CustomImageManager share] photoFromFetchResult:self.model.result isPickingVideo:YES isPickingImage:YES completion:^(NSArray<CustomAssetModel *> *models) {
        self.photos = [NSMutableArray arrayWithArray:models];
        [self checkSelectedModels];
        [self setupCollectionView];
    }];
}

- (void)checkSelectedModels {
    // 檢查照片是否已選擇
    for (CustomAssetModel *model in self.photos) {
        model.isSelected = NO;
        NSMutableArray *selectedAssets = [NSMutableArray array];
        for (CustomAssetModel *model in [CustomImageManager share].selectedModels) {
            [selectedAssets addObject:model.asset];
        }
        if ([selectedAssets containsObject:model.asset]) {
            model.isSelected = YES;
        }
    }
}

-(void)setupCollectionView{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 2);
    self.collectionView.collectionViewLayout = [self setupCollectionViewFlowLayout];
    self.collectionView.contentSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), ((self.model.count + 4) / 4) * CGRectGetWidth([UIScreen mainScreen].bounds));
    [self.collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCollectionViewCell"];
    [self.collectionView registerClass:[CameraCollectionViewCell class] forCellWithReuseIdentifier:@"CameraCollectionViewCell"];
}

-(UICollectionViewFlowLayout*)setupCollectionViewFlowLayout{
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 4;
    CGFloat itemWH = (CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * margin - 4) / 4 - margin;
    collectionViewFlowLayout.itemSize = CGSizeMake(itemWH, itemWH);
    collectionViewFlowLayout.minimumInteritemSpacing = margin;
    collectionViewFlowLayout.minimumLineSpacing = margin;
    return collectionViewFlowLayout;
}

-(void)setupButtons{
    
    //原圖按鈕開關
    self.originalPhotoButton.enabled=[CustomImageManager share].selectedModels.count > 0;
    self.originalPhotoButton.selected = (self.isSelectOriginalPhoto && self.originalPhotoButton.enabled);;
    self.originalPhotoLable.hidden = (!_originalPhotoButton.isSelected);
    if (self.isSelectOriginalPhoto) [self calculateSelectedPhotoBytes];
    
    // 數量 ImageView
    self.numberImageView.hidden = [CustomImageManager share].selectedModels.count <= 0;
    
    // 數量 Label
    self.numberLable.hidden = [CustomImageManager share].selectedModels.count <= 0;
    self.numberLable.text = [NSString stringWithFormat:@"%zd",[CustomImageManager share].selectedModels.count];
    
    // 確定開關
    self.submitButton.enabled = [CustomImageManager share].selectedModels.count > 0;
}

-(void)setupButtonsBlock{
    // 確定按鈕
    [self.submitButton addBlockAction:^{
        NSMutableArray *photos = [NSMutableArray array];
        NSMutableArray *assets = [NSMutableArray array];
        NSMutableArray *infos = [NSMutableArray array];
        for (NSInteger i = 0; i < [CustomImageManager share].selectedModels.count; i++) {
            [photos addObject:@1];
            [assets addObject:@1];
            [infos addObject:@1];
        }
        
        for (NSInteger index = 0; index < [CustomImageManager share].selectedModels.count; index++) {
            CustomAssetModel *model = [CustomImageManager share].selectedModels[index];
            [[CustomImageManager share] photoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded){
                    return;
                }
                [self addPhotoToArray:photo info:info photos:photos assets:assets infos:infos index:index model:model];
                for (id item in photos)
                {
                    if ([item isKindOfClass:[NSNumber class]])
                        return;
                }
                [self.albumController.pickerDelegate imagePickerControllerDidFinishPickingPhotos:photos sourceAssets:assets isSelectOriginalPhoto:self.isSelectOriginalPhoto infos:infos];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    // 原圖按鈕
    [self.originalPhotoButton addBlockAction:^{
        self.originalPhotoButton.selected = !self.originalPhotoButton.isSelected;
        self.isSelectOriginalPhoto = self.originalPhotoButton.isSelected;
        self.originalPhotoLable.hidden = !self.originalPhotoButton.isSelected;
        if (self.isSelectOriginalPhoto) {
            [self calculateSelectedPhotoBytes];
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

-(void)addPhotoToArray:(UIImage *)photo info:(NSDictionary*)info photos:(NSMutableArray*)photos assets:(NSMutableArray*)assets infos:(NSMutableArray*)infos index:(NSInteger)index model:(CustomAssetModel *)model{
    if (photo) {
        [photos replaceObjectAtIndex:index withObject:photo];
    }
    
    if (info){
        [infos replaceObjectAtIndex:index withObject:info];
        [assets replaceObjectAtIndex:index withObject:model.asset];
    }
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CellType type = (CellType)indexPath.row;
    switch (type) {
        case CellTypeCamera:
        {
            CameraCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CameraCollectionViewCell" forIndexPath:indexPath];
            return cell;
        }
        default:
        {
            PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
            CustomAssetModel *model = self.photos [indexPath.row - 1];
            cell.model = model;
            cell.delegate = self;
            return cell;
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CellType type = (CellType)indexPath.row;
    switch (type) {
        case CellTypeCamera:
            [self openCameraController];
            break;
        default:
        {
            break;
        }
    }
}

#pragma mark - Cancel Action

- (void)cancelAction {
    [self.albumController.pickerDelegate imagePickerControllerDidCancel];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)openCameraController {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) ) {
        NSLog(@"無權限");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.sourceType = sourceType;
        self.imagePickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [[CustomImageManager share] savePhotoWithImage:image completion:^{
            [self updateCollectionView];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter / setter

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
    return _imagePickerController;
}

#pragma mark - misc

- (void)updateCollectionView {
    [[CustomImageManager share] cameraRollAlbumPickingVideo:YES isPickingImage:YES completion:^(AlbumModel *model) {
        self.model = model;
        [[CustomImageManager share]photoFromFetchResult:self.model.result isPickingVideo:YES isPickingImage:YES completion:^(NSArray<CustomAssetModel *> *models) {
            // 將最新的照片插到最前面
            CustomAssetModel *assetModel = [models firstObject];
            [self.photos insertObject:assetModel atIndex:0];
            [self assetModelSelected:assetModel];
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }];
    }];
}

-(void)assetModelSelected:(CustomAssetModel *)assetModel{
    // 當選三張以下使才幫 User 勾選圖片
    if ([CustomImageManager share].selectedModels.count <= 3) {
        assetModel.isSelected = YES;
        [[CustomImageManager share].selectedModels addObject:assetModel];
    }
}

-(void)calculateSelectedPhotoBytes{
    [[CustomImageManager share] calculatePhotosBytesWithArray:[CustomImageManager share].selectedModels completion:^(NSString *totalBytes) {
        self.originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValue];
    [self setupNavigationBar];
    [self setupPhotoFetch];
    [self setupButtonsBlock];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupButtons];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.upDataHandle) {
        self.upDataHandle(self.model);
    }
}
@end
