//
//  AlbumTableViewCell.h
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumModel.h"

@interface AlbumTableViewCell : UITableViewCell

@property (nonatomic, strong) AlbumModel *model;

/**
 @abstract 主要顯示已勾選數量次數
 */
@property (weak, nonatomic) IBOutlet UIButton *selectedCountButton;

/**
 @abstract 主要顯示已勾選數量次數
 */
@property (weak, nonatomic)IBOutlet UIImageView *albumImageView;

/**
 @abstract 相簿名稱
 */
@property (weak, nonatomic)IBOutlet UILabel *titleLable;

@end
