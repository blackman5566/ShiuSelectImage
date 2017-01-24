//
//  ViewController.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/25.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "ViewController.h"
#import "CustomAlbumController.h"
#import "CustomImageManager.h"

@interface ViewController ()<UIActionSheetDelegate,CustomAlbumControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;

@end

@implementation ViewController

- (IBAction)selectImageAction:(id)sender {
    // 開啟照片選擇器
    CustomAlbumController *albumPickerController = [[CustomAlbumController alloc]init];
    albumPickerController.pickerDelegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:albumPickerController];
    [self.navigationController showViewController:navigationController sender:self];
}

#pragma mark - CustomAlbumControllerDelegate

- (void)imagePickerControllerDidCancel{
    //取消
}

- (void)imagePickerControllerDidFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos{
    // 選擇調用的 Delegate
    if (photos.count==0) {
        return;
    }
    NSArray *images = @[self.imageView1,self.imageView2,self.imageView3];
    for (NSInteger index = 0; index < photos.count; index++) {
       UIImageView *imageView = images[index];
        imageView.image = photos[index];
    }
}

@end
