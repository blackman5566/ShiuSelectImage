//
//  AlbumModel.h
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface AlbumModel : NSObject

/**
 @abstract 相簿名稱
 */
@property (nonatomic, strong) NSString *name;

/**
 @abstract 相簿內照片的數量
 */
@property (nonatomic, assign) NSInteger count;

/**
 @abstract 相簿 ID
 */
@property (nonatomic, strong) PHFetchResult *result;

/**
 @abstract 儲存相簿內所以照片的 CustomAssetModel
 */
@property (nonatomic, strong) NSArray *models;

/**
 @abstract 相簿內已選擇的照片
 */
@property (nonatomic, strong) NSArray *selectedModels;

/**
 @abstract 相簿內已選擇的總共數量
 */
@property (nonatomic, assign) NSUInteger selectedCount;

@end
