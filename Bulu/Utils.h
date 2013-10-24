//
//  Utils.h
//  Bulu
//
//  Created by apple on 13/2/21.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

- (BOOL)upload_to_s3:(UIImage*)img underName:(NSString*)filename;

@end
