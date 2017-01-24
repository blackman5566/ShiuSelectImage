//
//  CameraCollectionViewCell.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/29.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "CameraCollectionViewCell.h"

@implementation CameraCollectionViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.cameraImageView = [[UIImageView alloc] init];
    self.cameraImageView.frame = self.bounds;
    self.cameraImageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    self.cameraImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.cameraImageView.image = [UIImage imageNamed:@"takePicture"];
    [self addSubview:self.cameraImageView];
}

@end
