//
//  AlbumModel.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "AlbumModel.h"
#import "CustomAssetModel.h"
#import "CustomImageManager.h"

@implementation AlbumModel

#pragma mark - getter / setter

- (void)setResult:(PHFetchResult*)result {
    _result = result;
    
    // 獲得這相本的所有照片的資訊
    [[CustomImageManager share] photoFromFetchResult:result isPickingVideo:YES isPickingImage:YES completion:^(NSArray<CustomAssetModel *> *models) {
        self.models = models;
        if (self.selectedModels) {
            [self checkSelectedModels];
        }
    }];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (self.models) {
        [self checkSelectedModels];
    }
}

#pragma mark - private method

// 檢查是否有勾選圖片，當有勾選時 selectedCount 會加一，主要顯示在 AlbumTableViewCell 的 selectedCountButton 。

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (CustomAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    
    for (CustomAssetModel *model in self.models) {
        if ([selectedAssets containsObject:model.asset]) {
             self.selectedCount ++;
        }
    }
}

@end
