//
//  Utils.m
//  Bulu
//
//  Created by apple on 13/2/21.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import "Utils.h"

#import "NSData_Base64.h"
#import "NSData_HMAC_SHA1.h"

@implementation Utils

- (BOOL)upload_to_s3:(UIImage*)img underName:(NSString*)filename
{
    NSString* image_quality_str = [[NSUserDefaults standardUserDefaults] stringForKey:@"image_quality"];
    if (!image_quality_str) {
        image_quality_str = @"4096";
    }
    int image_quality = [image_quality_str intValue];
    image_quality = image_quality > 4096 ? 4096 : image_quality;
    image_quality = image_quality < 512 ? 512 : image_quality;
    
    // Convert img to NSData
    CGSize size = [img size];
    CGFloat ratio = image_quality / (size.width > size.height ? size.width : size.height);
    ratio = (ratio > 1.0 ? 1.0 : ratio);
    UIGraphicsBeginImageContext(CGSizeMake(size.width*ratio, size.height*ratio));
    [img drawInRect:CGRectMake(0, 0, size.width*ratio, size.height*ratio)];
    UIImage* newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData* data = UIImageJPEGRepresentation(newImg, 0.5);
    
    NSString* bucket_name = @"abcd";
    NSString* access_key_id = @"abcd";
    NSString* secret_access_key = @"abcd";
    
    // Prepare dateString
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    // Prepare authorization header
    NSString* stringToSign = [NSString stringWithFormat:@"PUT\n\nimage/jpeg\n%@\nx-amz-acl:public-read\n/%@/expires_in_days/7/bulu/%@.jpg", dateString, bucket_name, filename];
    NSString* signature = [[[stringToSign dataUsingEncoding:NSStringEncodingConversionAllowLossy]
                            HMAC_SHA1_with_secret:secret_access_key] base64EncodedString];
    
    // Prepare the NSURLRequest
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [req setHTTPShouldHandleCookies:NO];
    [req setTimeoutInterval:30];
    [req setHTTPMethod:@"PUT"];
    [req setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [req setValue:dateString forHTTPHeaderField:@"Date"];
    [req setValue:[NSString stringWithFormat:@"AWS %@:%@", access_key_id, signature] forHTTPHeaderField:@"Authorization"];
    [req setValue:@"public-read" forHTTPHeaderField:@"x-amz-acl"];
    [req setHTTPBody:data];
    [req setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://s3.amazonaws.com/%@/expires_in_days/7/bulu/%@.jpg", bucket_name, filename]]];
    
    // Start the connection
    NSURLResponse* resp = nil;
    NSError* err = nil;
    NSData* respData = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&err];
    if (err) {
        NSLog(@"%@", err);
        return NO;
    } else {
        NSLog(@"%@", [NSString stringWithUTF8String:(char*)[respData bytes]]);
        return YES;
    }
}

@end
