//
//  PhotoCollectionViewCell.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/29.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "CustomImageManager.h"

@interface PhotoCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLength;
@property (weak, nonatomic) IBOutlet UIImageView *videoRecorderImageVIew;

@end
@implementation PhotoCollectionViewCell

#pragma mark - getter / setter

- (void)setModel:(CustomAssetModel *)model {
    _model = model;
    PHAsset *asset = model.asset;
    self.representedAssetIdentifier = asset.localIdentifier;
    // 設定每一個 cell 的圖片
    PHImageRequestID imageRequestID = [[CustomImageManager share]photoWithAsset:model.asset photoWidth:self.frame.size.width completion:^(UIImage *photo, NSDictionary * info, BOOL isDegraded) {
        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            self.photoImageView.image = photo;
        } else {
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    }];
    
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamed:@"photo_sel_photoPickerVc"] : [UIImage imageNamed:@"photo_def_photoPickerVc"];
    [self setupType];
}

- (void)setType:(PhotoCellType)type {
    _type = type;
    if (type == PhotoCellTypePhoto || type == PhotoCellTypeLivePhoto) {
        self.selectImageView.hidden = NO;
        self.selectPhotoButton.hidden = NO;
        self.bottomView.hidden = YES;
    } else {
        self.selectImageView.hidden = YES;
        self.selectPhotoButton.hidden = YES;
        self.bottomView.hidden = NO;
    }
}

- (IBAction)selectPhotoButtonClick:(UIButton*)sender {
    [self.delegate didSelectPhoto:self isSelect:sender.isSelected];
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:@"photo_sel_photoPickerVc"] : [UIImage imageNamed:@"photo_def_photoPickerVc"];
    if (sender.isSelected) {
        [PhotoCollectionViewCell showOscillatoryAnimationWithLayer:self.selectImageView.layer type:TZOscillatoryAnimationToBigger];
    }

}

- (UIButton *)selectPhotoButton {
    if (_selectImageView == nil) {
        UIButton *selectImageView = [[UIButton alloc] init];
        selectImageView.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
        [selectImageView addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectImageView];
        _selectPhotoButton = selectImageView;
    }
    return _selectPhotoButton;
}

- (UIImageView *)photoImageView {
    if (_photoImageView == nil) {
        UIImageView *photoImageView = [[UIImageView alloc] init];
        photoImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        photoImageView.clipsToBounds = YES;
        [self.contentView addSubview:photoImageView];
        _photoImageView = photoImageView;
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _photoImageView;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.frame = CGRectMake(self.frame.size.width - 27, 0, 27, 27);
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.frame.size.height - 17, self.frame.size.width, 17);
        bottomView.backgroundColor = [UIColor blackColor];
        bottomView.alpha = 0.8;
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)videoRecorderImageVIew {
    if (_videoRecorderImageVIew == nil) {
        UIImageView *viewImgView = [[UIImageView alloc] init];
        viewImgView.frame = CGRectMake(8, 0, 17, 17);
        [viewImgView setImage:[UIImage imageNamed:@"VideoSendIcon.png"]];
        [self.bottomView addSubview:viewImgView];
        _videoRecorderImageVIew = viewImgView;
    }
    return _videoRecorderImageVIew;
}

- (UILabel *)timeLength {
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        CGFloat rightPoint= self.videoRecorderImageVIew.frame.origin.x + self.videoRecorderImageVIew.frame.size.width;
        timeLength.frame = CGRectMake(rightPoint, 0, self.frame.size.width - rightPoint - 5, 17);
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

-(void)setupType{
    self.type = PhotoCellTypePhoto;
//    if (model.type == PhotoCellTypeLivePhoto)      self.type = PhotoCellTypeLivePhoto;
//    else if (model.type == PhotoCellTypeAudio)     self.type = PhotoCellTypeAudio;
//    else if (model.type == PhotoCellTypeVideo) {
//        self.type = PhotoCellTypeVideo;
//        self.timeLength.text = model.timeLength;
//    }
}

#pragma mark - public class method

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(TZOscillatoryAnimationType)type{
    NSNumber *animationScale1 = type == TZOscillatoryAnimationToBigger ? @(1.15) : @(0.5);
    NSNumber *animationScale2 = type == TZOscillatoryAnimationToBigger ? @(0.92) : @(1.15);
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:animationScale1 forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:animationScale2 forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}

@end
