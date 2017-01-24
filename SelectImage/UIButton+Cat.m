//
//  UIButton+Cat.m
//  CatDrink_ios
//
//  Created by AllenShiu on 2016/7/20.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "UIButton+Cat.h"
#import <objc/runtime.h>

@implementation UIButton (Cat)

#pragma mark - private instance method

- (void)invokeBlockAction {
    BlockAction blockAction = [self blockAction];
    if (blockAction) {
        blockAction();
    }
}

#pragma mark - instance method

- (void)addBlockAction:(BlockAction)blockAction forControlEvents:(UIControlEvents)controlEvents {
    [self setBlockAction:blockAction];
    [self addTarget:self action:@selector(invokeBlockAction) forControlEvents:controlEvents];
}

- (void)addCenterImage:(UIImage *)image {
    CGRect newFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:newFrame];
    imageView.image = image;
    [self addSubview:imageView];
    
    // 設定文字圖片 autolayout
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *widthLayout = [NSString stringWithFormat:@"H:[superview]-(<=1)-[imageView(%f)]", image.size.width];
    NSString *heightLayout = [NSString stringWithFormat:@"V:[superview]-(<=1)-[imageView(%f)]", image.size.height];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthLayout options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{ @"imageView" : imageView, @"superview" : self }]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightLayout options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{ @"imageView" : imageView, @"superview" : self }]];
}

- (void)addRightImage:(UIImage *)image {
    CGRect newFrame = CGRectMake(CGRectGetWidth(self.frame), 0, image.size.width, image.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:newFrame];
    imageView.image = image;
    [self addSubview:imageView];
    
    // 設定文字圖片 autolayout
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *widthLayout = [NSString stringWithFormat:@"H:[superview]-(<=1)-[imageView(%f)]", image.size.width];
    NSString *heightLayout = @"H:|-(>=0)-[imageView]-8-|";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightLayout options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{ @"imageView" : imageView }]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthLayout options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{ @"imageView" : imageView , @"superview" : self }]];
}

#pragma mark - runtime objects

- (void)setBlockAction:(BlockAction)blockAction {
    objc_setAssociatedObject(self, @selector(blockAction), blockAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BlockAction)blockAction {
    return objc_getAssociatedObject(self, _cmd);
}

@end
