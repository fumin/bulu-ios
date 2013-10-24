//
//  MessageReceiver.h
//  Bulu
//
//  Created by apple on 13/2/17.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AJNBusAttachment.h"

#import "Constants.h"

@protocol MessageReceiver <NSObject>

@optional

- (void)buluMessageReceived:(NSString*)username type:(NSString*)messageType data:(NSString *)message
                       from:(NSString *)sender onObjectPath:(NSString *)path forSession:(AJNSessionId)sessionId;

@end

void createBuluInterface(AJNBusAttachment* busAttachment);
