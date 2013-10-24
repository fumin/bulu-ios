//
//  BuluUtils.m
//  Bulu
//
//  Created by apple on 13/2/21.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import "BuluUtils.h"
#import "UIImage_ResizeData.h"
#import "NSString_RandomStr.h"
#import "NSData_HMAC_SHA1.h"
#import "NSData_Hex.h"

@implementation BuluUtils

- (NSString*)saveImageAsThumbnailAndOriginal:(UIImage*)img
{
    UIImage* thumbnail = [img resizeDataWithMaxSize:128];
    time_t current_time = time(NULL);
    NSString* randomStr = [NSString stringFromRandomStrWithLength:8];
    NSString* fileName = [NSString stringWithFormat:@"%d_%@", (int)current_time, randomStr];
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* newDir = [docDir stringByAppendingPathComponent:fileName];
    NSError* err = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error:&err];
    
    // Save thumbnail
    NSString* thumbnailPath = [newDir stringByAppendingPathComponent:@"thumbnail.png"];
    NSData* thumbnailData = UIImagePNGRepresentation(thumbnail);
    [thumbnailData writeToFile:thumbnailPath atomically:YES];
    
    // Save original
    NSString* originalPath = [newDir stringByAppendingPathComponent:@"original.png"];
    [UIImagePNGRepresentation(img) writeToFile:originalPath atomically:YES];
    
    // Experimental, save fullscreen
    NSString* fullScreenPath = [newDir stringByAppendingPathComponent:@"fullScreen.png"];
    UIImage* fullScreenImg = [img resizeDataWithMaxSize:1024];
    [UIImagePNGRepresentation(fullScreenImg) writeToFile:fullScreenPath atomically:YES];
    
    return fileName;
}

- (BOOL) deleteImageFromFileName:(NSString*)fileName
{
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [docDir stringByAppendingPathComponent:fileName];
    NSError* err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
    if (!err) {
        return YES;
    } else {
        return NO;
    }
}

- (UIImage*)fullScreenImageFromFileName:(NSString*)fileName
{
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/fullScreen.png", fileName]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (UIImage*)thumbnailFromFileName:(NSString*)fileName
{
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* thumbnailPath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/thumbnail.png", fileName]];
    UIImage* image = [UIImage imageWithContentsOfFile:thumbnailPath];
    return image;
}

- (UIImage*)originalImageFromFileName:(NSString*)fileName
{
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/original.png", fileName]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

@end
