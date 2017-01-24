//
//  PhotoCollectionViewCell.h
//  SelectImage
//
//  Created by AllenShiu on 2016/11/29.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "CustomAssetModel.h"

typedef enum : NSUInteger {
    TZOscillatoryAnimationToBigger,
    TZOscillatoryAnimationToSmaller,
} TZOscillatoryAnimationType;

typedef enum : NSUInteger {
    PhotoCellTypePhoto = 0,
    PhotoCellTypeLivePhoto,
    PhotoCellTypeVideo,
    PhotoCellTypeAudio,
} PhotoCellType;

@protocol PhotoCollectionViewCellDelegate;

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;

@property (nonatomic, weak) id <PhotoCollectionViewCellDelegate> delegate;

@property (nonatomic, strong) CustomAssetModel *model;
@property (nonatomic, strong) NSString *representedAssetIdentifier;

@property (nonatomic, assign) PhotoCellType type;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(TZOscillatoryAnimationType)type;

@end

@protocol PhotoCollectionViewCellDelegate <NSObject>
@required
- (void)didSelectPhoto:(PhotoCollectionViewCell*)cell isSelect:(BOOL)isSelect;
@end
