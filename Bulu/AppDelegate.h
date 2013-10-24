//
//  AppDelegate.h
//  Bulu
//
//  Created by apple on 13/2/16.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageSignalHandlerImpl.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MessageReceiver>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AJNBusAttachment *busAttachment;
@property (nonatomic, strong) AJNInterfaceDescription *buluInterface;
@property (nonatomic, assign) MessageSignalHandlerImpl* messageSignalHandlerImpl;

@end
