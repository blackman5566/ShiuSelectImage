//
//  CustomImagePickerController.h
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumModel.h"
#import "CustomAlbumController.h"

@interface CustomImagePickerController : UIViewController

@property (nonatomic, strong) AlbumModel *model;

@property (nonatomic, strong) CustomAlbumController *albumController;

@property (nonatomic, copy) void (^upDataHandle)(AlbumModel *model);

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@end
