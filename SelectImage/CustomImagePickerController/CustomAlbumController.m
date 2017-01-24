//
//  CustomAlbumController.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "CustomAlbumController.h"
#import "AlbumTableViewCell.h"
#import "CustomImageManager.h"
#import "CustomImagePickerController.h"

@interface CustomAlbumController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *albumTableView;
@property (nonatomic, strong) NSMutableArray *albumArray;

@end

@implementation CustomAlbumController

#pragma mark - private instance method

#pragma mark * setup

-(void)setupNavigationBar{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"相本";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
}

-(void)setupAlbumTableView{
    self.albumTableView.tableFooterView = [[UIView alloc] init];
    self.albumTableView.dataSource = self;
    self.albumTableView.delegate = self;
    self.albumTableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    [self.albumTableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil] forCellReuseIdentifier:@"AlbumTableViewCell"];
}

- (void)setupImageArray {
    if (self.albumArray) {
        [self updateSelectedModels];
    } else {
        [self setupAlbumArray];
    }
}

-(void)updateSelectedModels{
    // 當 albumArray已存在時，就做每本相簿的資訊更新
    for (AlbumModel *albumModel in self.albumArray) {
        albumModel.selectedModels = [CustomImageManager share].selectedModels;
    }
}

-(void)setupAlbumArray{
    // 取得目前手機上的相簿列表
    [[CustomImageManager share] allAlbumsPickingVideo:YES pickingImage:YES completion:^(NSArray<AlbumModel *> *models) {
        self.albumArray = [NSMutableArray arrayWithArray:models];
    }];
}

#pragma mark - Click Event

- (void)cancel {
    [self.pickerDelegate imagePickerControllerDidCancel];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumTableViewCell" forIndexPath:indexPath];
    cell.selectedCountButton.backgroundColor = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0];
    cell.model = self.albumArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CustomImagePickerController *imagePicker = [[CustomImagePickerController alloc] init];
    AlbumModel *model = self.albumArray[indexPath.row];
    imagePicker.albumController = self;
    imagePicker.model = model;
    __weak CustomAlbumController *weakSelf = self;
    [imagePicker setUpDataHandle:^(AlbumModel *model) {
        [weakSelf.albumArray replaceObjectAtIndex:indexPath.row withObject:model];
    }];
    [self.navigationController pushViewController:imagePicker animated:YES];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupAlbumTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupImageArray];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.albumTableView reloadData];
}

@end
