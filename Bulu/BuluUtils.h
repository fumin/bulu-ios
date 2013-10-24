//
//  BuluUtils.h
//  Bulu
//
//  Created by apple on 13/2/21.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuluUtils : NSObject

- (NSString*)saveImageAsThumbnailAndOriginal:(UIImage*)img;
- (BOOL) deleteImageFromFileName:(NSString*)fileName;

- (UIImage*)fullScreenImageFromFileName:(NSString*)fileName;
- (UIImage*)thumbnailFromFileName:(NSString*)fileName;
- (UIImage*)originalImageFromFileName:(NSString*)fileName;

@end
