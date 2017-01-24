//
//  CustomAlbumController.h
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomAlbumControllerDelegate;

@interface CustomAlbumController : UIViewController

@property (nonatomic, weak) id<CustomAlbumControllerDelegate> pickerDelegate;

@end

@protocol CustomAlbumControllerDelegate <NSObject>
@optional

/**
 @abstract 選完照片行為
 @discussion 當使用者選完照片時並按下確定扭回觸發此方法
 @param photos 回傳使用者的圖片(預設原始大小)
 @param assets 圖片的相關訊息
 @param isSelectOriginalPhoto 目前設定為原圖
 @param infos 圖片的相關訊息
 */
- (void)imagePickerControllerDidFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos;

/**
 @abstract 關閉照片選擇器的事件
 @discussion 使用者可以自行定義關閉照片選擇器之後的行為
 */
-(void)imagePickerControllerDidCancel;

@end
