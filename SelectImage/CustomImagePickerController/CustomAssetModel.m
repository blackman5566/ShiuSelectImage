//
//  CustomAssetModel.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "CustomAssetModel.h"
#import <UIKit/UIKit.h>

@implementation CustomAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(AssetModelMediaType)type{
    CustomAssetModel *model = [[CustomAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(AssetModelMediaType)type timeLength:(NSString *)timeLength {
    CustomAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end
