//
//  CustomAssetModel.h
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AssetModelMediaTypePhoto = 0,
    AssetModelMediaTypeLivePhoto,
    AssetModelMediaTypeVideo,
    AssetModelMediaTypeAudio
} AssetModelMediaType;

@class PHAsset;
@interface CustomAssetModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) AssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

+ (instancetype)modelWithAsset:(id)asset type:(AssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(AssetModelMediaType)type timeLength:(NSString *)timeLength;

@end
