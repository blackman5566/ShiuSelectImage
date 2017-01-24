//
//  UIButton+Cat.h
//  CatDrink_ios
//
//  Created by AllenShiu on 2016/7/20.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BlockAction)(void);

@interface UIButton (Cat)

/**
 @abstract 簡單設定 button action 的方法
 @discussion 由於 button 原先的做法, 需要給他一個 target, 和一個 selector, 在很多情況下, code 會變的破碎, 且不易管理, 所以產生這樣的做法
 @param blockAction 型別為 void(^BlockAction)(void) 的回調
 @param controlEvents 設定這個 button 要響應的 event 是哪一種
 @warning 需要注意的地方是 blockAction 只能針對某一個 UIControlEvents, 不能對多個
 */
- (void)addBlockAction:(BlockAction)blockAction forControlEvents:(UIControlEvents)controlEvents;

- (void)addCenterImage:(UIImage *)image;

- (void)addRightImage:(UIImage *)image;

@end
