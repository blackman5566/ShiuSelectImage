//
//  AlbumTableViewCell.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "AlbumTableViewCell.h"
#import "CustomImageManager.h"

@implementation AlbumTableViewCell

#pragma mark - getter / setter 

- (void)setModel:(AlbumModel *)model {
    _model = model;
    [self setupTitleLabel:model];
    [self setupAlbumImageView:model];
    [self setupSelectedCountButton:model];
}

#pragma mark - private method

#pragma mark - setup

-(void)setupTitleLabel:(AlbumModel *)model{
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLable.attributedText = nameString;
}

-(void)setupAlbumImageView:(AlbumModel *)model{
    // 取得相簿封面圖
    [[CustomImageManager share] albumCoverPhoto:model completion:^(UIImage *albumImage) {
        self.albumImageView.image = albumImage;
    }];
}

-(void)setupSelectedCountButton:(AlbumModel *)model{
    self.selectedCountButton.layer.cornerRadius = 15;
    self.selectedCountButton.clipsToBounds = YES;
    self.selectedCountButton.backgroundColor = [UIColor redColor];
    [self.selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
    // 顯示已選擇數量
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}

@end
