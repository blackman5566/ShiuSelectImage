//
//  CustomImageManager.m
//  SelectImage
//
//  Created by AllenShiu on 2016/11/28.
//  Copyright © 2016年 AllenShiu. All rights reserved.
//

#import "CustomImageManager.h"
#import "CustomImageManager+Orientation.h"

@implementation CustomImageManager

static CGSize AssetGridThumbnailSize;
static CGFloat ScreenWidth;
static CGFloat ScreenScale;
#pragma mark - class method

//共用同一個對象
+ (instancetype)share {
    static CustomImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.sortAscendingByModificationDate = NO;
        manager.shouldFixOrientation = NO;
        manager.photoPreviewMaxWidth = 600;
        manager.selectedModels = [NSMutableArray new];
        manager.cachingImageManager = [[PHCachingImageManager alloc] init];
        // 是否緩存高畫質照片(預設 YES)
        manager.cachingImageManager.allowsCachingHighQualityImages = NO;
        [self imageSize];
    });
    return manager;
}

+(void)imageSize{
    // 根據螢幕大小制定每一個 item 大小
    ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    ScreenScale = 2.0;
    if (ScreenWidth > 700) {
        ScreenScale = 1.5;
    }
    
    CGFloat margin = 4;
    CGFloat itemWH = (ScreenWidth - 2 * margin - 4) / 4 - margin;
    AssetGridThumbnailSize = CGSizeMake(itemWH * ScreenScale, itemWH * ScreenScale);
}

#pragma mark - public method

#pragma mark - all albums (獲得所有相本的資訊)

- (void)allAlbumsPickingVideo:(BOOL)isPickingVideo pickingImage:(BOOL)isPickingImage completion:(void (^)(NSArray<AlbumModel *> *))completion{
    // 獲得所有相本
    NSMutableArray *albumArray = [NSMutableArray array];
    PHFetchOptions *option = [self setupPHFetchOptionsPickingVideo:isPickingVideo isPickingImage:isPickingImage];
    PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumVideos;
    if (iOS9Later) {
        smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumSelfPortraits | PHAssetCollectionSubtypeSmartAlbumVideos;
    }
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:smartAlbumSubtype options:nil];
    
    for (PHAssetCollection *collection in smartAlbums) {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count < 1) continue;
        if ([collection.localizedTitle containsString:@"Deleted"] ||
            [collection.localizedTitle isEqualToString:@"最近刪除"]) continue;
        if ([collection.localizedTitle isEqualToString:@"Camera Roll"] ||
            [collection.localizedTitle isEqualToString:@"相機膠卷"]) {
            [albumArray insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:0];
        } else {
            [albumArray addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
        }
    }
    
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    for (PHAssetCollection *collection in albums) {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count < 1) continue;
        if ([collection.localizedTitle isEqualToString:@"My Photo Stream"] || [collection.localizedTitle isEqualToString:@"我的照片串流"]) {
            [albumArray insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:1];
        } else {
            [albumArray addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
        }
    }
    
    // 最後檢查是否有資料
    if (completion && albumArray.count > 0) {
        completion(albumArray);
    }
}

- (void)albumCoverPhoto:(AlbumModel *)model completion:(void (^)(UIImage *))completion {
    /// 獲得相本封面圖
    PHAsset *asset = [model.result firstObject];
    [[CustomImageManager share] photoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo);
        }
    }];
}

- (void)cameraRollAlbumPickingVideo:(BOOL)isPickingVideo isPickingImage:(BOOL)isPickingImage completion:(void (^)(AlbumModel *))completion{
    __block AlbumModel *model;
    PHFetchOptions *option = [self setupPHFetchOptionsPickingVideo:isPickingVideo isPickingImage:isPickingImage];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        if ([collection.localizedTitle isEqualToString:@"Camera Roll"]
            || [collection.localizedTitle isEqualToString:@"相機膠卷"]
            || [collection.localizedTitle isEqualToString:@"所有照片"]
            || [collection.localizedTitle isEqualToString:@"All Photos"])
        {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            model = [self modelWithResult:fetchResult name:collection.localizedTitle];
            if (completion) {
                completion(model);
            }
            break;
        }
    }
}

#pragma mark * albums private method

- (AlbumModel *)modelWithResult:(PHFetchResult *)fetchResult name:(NSString *)name{
    AlbumModel *model = [[AlbumModel alloc] init];
    model.result = fetchResult;
    model.name = [self albumName:name];
    model.count = fetchResult.count;
    return model;
}

- (NSString *)albumName:(NSString *)name {
    NSString *newName = name;
    NSArray *albumNames = @[@"Roll", @"Stream",@"Added",@"Selfies",@"shots",@"Videos",@"Panoramas",@"Favorites"];
    NSDictionary *albumDictionary = @{ @"Roll" : @"相機膠卷", @"Stream": @"我的照片串流", @"Added" : @"最近新增", @"Selfies" : @"自拍" ,@"shots":@"截圖",@"Videos":@"影片",@"Panoramas":@"全景照片",@"Favorites":@"個人收藏"};
    for (NSInteger index = 0; index < albumNames.count; index++) {
        NSString *albumName = albumNames[index];
        if ([newName rangeOfString:albumName].location != NSNotFound) {
            newName = albumDictionary[albumName];
        }
    }
    return newName;
}

-(PHFetchOptions*)setupPHFetchOptionsPickingVideo:(BOOL)isPickingVideo isPickingImage:(BOOL)isPickingImage{
   PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (!isPickingVideo) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    
    if (!isPickingImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                             PHAssetMediaTypeVideo];
    }
    
    // option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:self.sortAscendingByModificationDate]];
    return options;
}


#pragma mark - 獲得某一本相本的所有照片資訊

- (void)photoFromFetchResult:(PHFetchResult*)fetchResult isPickingVideo:(BOOL)isPickingVideo isPickingImage:(BOOL)isPickingImage completion:(void (^)(NSArray<CustomAssetModel *> *))completion {
    NSMutableArray *photos = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset*  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        AssetModelMediaType type = [self optionType:asset];
        NSString *timeLength = type == AssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",asset.duration] : @"";
        timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
        [photos addObject:[CustomAssetModel modelWithAsset:asset type:type timeLength:timeLength]];
    }];
    
    // 回傳所有相本的照片資訊
    if (completion) {
        completion(photos);
    }
}

-(AssetModelMediaType)optionType:(PHAsset*)asset{
    // 每個檔案型態不一樣，有影片圖片還有PhotoLive,所以做分類並存起來
    AssetModelMediaType type = AssetModelMediaTypePhoto ;
    switch (asset.mediaType) {
        case PHAssetMediaTypeVideo:
            type = AssetModelMediaTypeVideo;
            break;
        case PHAssetMediaTypeAudio:
            type = AssetModelMediaTypeAudio;
            break;
        case PHAssetMediaTypeImage:
        {
            if (iOS9_1Later && asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                type = AssetModelMediaTypeLivePhoto;
            }
            break;
        }
        case PHAssetMediaTypeUnknown:
            break;
    }
    return type;
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    // 計算影片的總時間
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

#pragma mark - 獲得相簿每一張照片

- (PHImageRequestID)photoWithAsset:(PHAsset*)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
    CGSize imageSize = [self setupImageSize:photoWidth asset:asset];
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
           //判斷 PHImageCancelledKey PHImageErrorKey 是否為 NO，如果是代表 download 完成直接回傳圖片。
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                result = [self fixOrientation:result];
                if (completion){
                    completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }
        
           //判斷是否為 Cloud 圖庫 是的話就執行下載動作
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [self scaleImage:resultImage toSize:imageSize];
                    if (resultImage) {
                        resultImage = [self fixOrientation:resultImage];
                        if (completion) {
                         completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                        }
                    }
                }];
            }
        }];
        return imageRequestID;
    }
    return 0;
}

- (void)originalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable originalPhoto, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && originalPhoto) {
                originalPhoto = [self fixOrientation:originalPhoto];
                if (completion) completion(originalPhoto,info);
            }
        }];
}

#pragma mark - misc

- (void)calculatePhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion{
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        CustomAssetModel *model = photos[i];
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (model.type != AssetModelMediaTypeVideo)
            {
                dataLength += imageData.length;
            }
            assetCount ++;
            if (assetCount >= photos.count) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) completion(bytes);
            }
        }];
    }
}

- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}


-(CGSize)setupImageSize:(CGFloat)photoWidth asset:(PHAsset *)asset{
    // 回傳每個圖片的大小
    CGSize imageSize = CGSizeZero;
    if (photoWidth < ScreenWidth && photoWidth < self.photoPreviewMaxWidth) {
        imageSize = AssetGridThumbnailSize;
    } else {
        CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
        CGFloat pixelWidth = photoWidth * ScreenScale;
        CGFloat pixelHeight = photoWidth / aspectRatio;
        imageSize = CGSizeMake(pixelWidth, pixelHeight);
    }
    return imageSize;
}

- (PHImageRequestID)photoWithAsset:(PHAsset*)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    // 得到原始圖片
    CGFloat fullScreenWidth = ScreenWidth;
    if (fullScreenWidth > self.photoPreviewMaxWidth) {
        fullScreenWidth = self.photoPreviewMaxWidth;
    }
    return [self photoWithAsset:asset photoWidth:fullScreenWidth completion:completion];
}

- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)())completion {
    // 儲存照片
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    if (iOS9Later) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    completion();
                } else if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                }
            });
        }];
    }
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    // 縮放圖片
    if (image.size.width < size.width) {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
