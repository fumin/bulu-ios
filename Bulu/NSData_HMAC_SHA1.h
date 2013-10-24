//
//  NSData_HMAC_SHA1.h
//  Bulu
//
//  Created by apple on 13/2/17.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@interface NSData (HMAC_SHA1)

- (NSData*)HMAC_SHA1_with_secret:(NSString*)secret;
- (NSData*)MD5;

@end

@implementation NSData (HMAC_SHA1)
/*
+(NSString *) HMACSign:(NSData *)data withKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm
{
    CCHmacContext context;
    const char    *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];
    
    CCHmacInit(&context, algorithm, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [data bytes], [data length]);
    
    // Both SHA1 and SHA256 will fit in here
    unsigned char digestRaw[CC_SHA256_DIGEST_LENGTH];
    
    NSInteger           digestLength;
    
    switch (algorithm) {
        case kCCHmacAlgSHA1:
            digestLength = CC_SHA1_DIGEST_LENGTH;
            break;
            
        case kCCHmacAlgSHA256:
            digestLength = CC_SHA256_DIGEST_LENGTH;
            break;
            
        default:
            digestLength = -1;
            break;
    }
    
    if (digestLength < 0)
    {
        // Fatal error. This should not happen.
        @throw [AmazonSignatureException exceptionWithName : kError_Invalid_Hash_Alg
                                                    reason : kReason_Invalid_Hash_Alg
                                                  userInfo : nil];
    }
    
    CCHmacFinal(&context, digestRaw);
    
    NSData *digestData = [NSData dataWithBytes:digestRaw length:digestLength];
    
    return [digestData base64EncodedString];
}*/

- (NSData*)HMAC_SHA1_with_secret:(NSString*)secret
{
    CCHmacContext context;
    const char* keyCString = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    CCHmacInit(&context, kCCHmacAlgSHA1, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [self bytes], [self length]);
    
    unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];
    CCHmacFinal(&context, digestRaw);
    return [NSData dataWithBytes:digestRaw length:CC_SHA1_DIGEST_LENGTH];
    
    /*
    const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = (char*)[self bytes];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];*/
}

- (NSData*)MD5
{
    int self_len = [self length];
    char* cData = (char*)malloc(self_len);
    memcpy(cData, [self bytes], self_len);
    
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cData, self_len, md5Buffer);

    free(cData);
    
    return  [[NSData alloc] initWithBytes:md5Buffer length:sizeof(md5Buffer)];
}

@end
