//
//  CustomImageManager+Orientation.h
//  SelectImage
//
//  Created by AllenShiu on 2016/11/30.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "CustomImageManager.h"

@interface CustomImageManager (Orientation)

- (UIImage *)fixOrientation:(UIImage *)originalImage;

@end
