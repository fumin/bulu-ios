//
//  UIImage_ResizeData.h
//  Bulu
//
//  Created by apple on 13/2/25.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizeData)

- (UIImage*)resizeDataWithMaxSize:(CGFloat)maxSize;

@end

@implementation UIImage (ResizeData)

- (UIImage*)resizeDataWithMaxSize:(CGFloat)maxSize
{
    CGSize size = [self size];
    CGFloat ratio = maxSize / (size.width > size.height ? size.width : size.height);
    ratio = (ratio > 1.0 ? 1.0 : ratio);
    UIGraphicsBeginImageContext(CGSizeMake(size.width*ratio, size.height*ratio));
    [self drawInRect:CGRectMake(0, 0, size.width*ratio, size.height*ratio)];
    UIImage* newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImg;
}

@end
