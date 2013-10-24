//
//  NSString_RandomStr.h
//  Bulu
//
//  Created by apple on 13/2/17.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RandomStr)
+ (NSString*)stringFromRandomStrWithLength:(int)len;
@end


@implementation NSString (RandomStr)

+ stringFromRandomStrWithLength:(int)len
{
    NSString *randomString = @"";
    for (int x=0;x<len;x++) {
        randomString = [randomString stringByAppendingFormat:@"%c", (char)(65 + (arc4random() % 25))];
    }
    return randomString;
}

@end
