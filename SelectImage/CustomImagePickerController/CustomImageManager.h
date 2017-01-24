//
//  CustomImageManager.h
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "AlbumModel.h"
#import "CustomAssetModel.h"

#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

@interface CustomImageManager : NSObject

+ (instancetype)share;

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

/**
 @abstract 設定照片是否要轉換正確的方向。預設 YES
 */
@property (nonatomic, assign) BOOL shouldFixOrientation;

/**
 @abstract 設定照片 Preview 像素。  預設 600px
 */
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/**
 @abstract 儲存使用者選中過的圖片
 */
@property (nonatomic, strong) NSMutableArray<CustomAssetModel *> *selectedModels;

/**
 @abstract 照片以時間進行排序，預設為YES
 @discussion 如果設置為 NO 最新照片會在最前面，拍照按鈕會擺第一個
 */
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

///---------------------------------------------------------------------------------------
/// @name 取得相簿相關方法
///---------------------------------------------------------------------------------------
/**
 @abstract 獲得單一相本所有照片資訊
 @discussion 獲得單一相本的所有照片資訊資訊
 @param fetchResult 所選相本
 @param isPickingVideo 相本內容是否要包含 video
 @param isPickingImage 相本內容是否要包含 image
 @param completion 回傳所有照片的陣列 
 */
- (void)photoFromFetchResult:(PHFetchResult*)fetchResult isPickingVideo:(BOOL)isPickingVideo isPickingImage:(BOOL)isPickingImage completion:(void (^)(NSArray<CustomAssetModel *> *))completion;

/**
 @abstract 獲得相本封面圖片
 @discussion 獲得相本封面圖片
 @param model 相簿相關資訊
 @param completion 回傳相簿照片
 */
- (void)albumCoverPhoto:(AlbumModel *)model completion:(void (^)(UIImage *))completion;

/**
 @abstract 獲得所有相本的資訊
 @discussion 獲得所有相本的資訊
 @param isPickingVideo 相本內容是否要包含 video
 @param isPickingImage 相本內容是否要包含 image
 */
- (void)allAlbumsPickingVideo:(BOOL)isPickingVideo pickingImage:(BOOL)isPickingImage completion:(void (^)(NSArray<AlbumModel *> *models))completion;

/**
 @abstract 獲得所有相本的資訊
 @discussion 獲得所有相本的資訊
 @param isPickingVideo 相本內容是否要包含 video
 @param isPickingImage 相本內容是否要包含 image
 */
- (void)cameraRollAlbumPickingVideo:(BOOL)isPickingVideo isPickingImage:(BOOL)isPickingImage completion:(void (^)(AlbumModel *models))completion;

/**
 @abstract 獲得該相簿的每一張照片
 @discussion 獲得每一張照片 image
 @param photoWidth 設定照片尺寸
 */
- (PHImageRequestID)photoWithAsset:(PHAsset*)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion;

/**
 @abstract 獲得照片
 @discussion 獲得照片 image
 @param asset 設定照片
 @param completion 回傳照片
 */
- (PHImageRequestID)photoWithAsset:(PHAsset*)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion;

/**
 @abstract 按照比例縮放圖片
 @discussion 按照比例縮放圖片
 @param image 原始圖片
 @param size 轉換的大小
 */
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

/**
 @abstract 儲存拍照的照片
 @discussion 儲存拍照的照片
 @param image 所拍攝的照片
 */
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)())completion;

/**
 @abstract 獲得一組照片的大小
 @discussion 會自動幫使用者計算一組圖片的大小
 @param photos 照片的陣列
 @param completion 回傳大小
 */
- (void)calculatePhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;

/**
 @abstract 獲得原始大小照片
 @discussion 獲得原始大小照片
 @param asset 設定照片
 @param completion 回傳照片
 */
- (void)originalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

@end
