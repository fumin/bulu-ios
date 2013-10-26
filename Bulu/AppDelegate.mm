//
//  AppDelegate.m
//  Bulu
//
//  Created by apple on 13/2/16.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import "AppDelegate.h"

#import "Constants.h"
#import "TimelineViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self customSetup];
    [self readS3Credentials];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.busAttachment) {
        self.messageSignalHandlerImpl->UnregisterSignalHandler(*(ajn::BusAttachment*)self.busAttachment.handle);
        delete self.messageSignalHandlerImpl;
        self.messageSignalHandlerImpl = nil;
        self.busAttachment = nil;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self customSetup];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)customSetup
{
    self.busAttachment = [[AJNBusAttachment alloc] initWithApplicationName:kAppName allowRemoteMessages:YES];
    createBuluInterface(self.busAttachment);
    
    // register signal handler
    ajn::BusAttachment* bus = (ajn::BusAttachment*)self.busAttachment.handle;
    // self is messageSignalHandlerImpl's delegate
    self.messageSignalHandlerImpl = new MessageSignalHandlerImpl(self, [kServicePath UTF8String]);
    self.messageSignalHandlerImpl->RegisterSignalHandler(*bus);
    
    bus->RegisterBusObject(*self.messageSignalHandlerImpl);
    
    // start the bus
    QStatus status = ER_OK;
    status = [self.busAttachment start];
    if (status != ER_OK) {NSLog(@"ERROR: Failed to start bus. %@", [AJNStatus descriptionForStatusCode:status]);}
    
    status = [self.busAttachment connectWithArguments:@"null:"];
    if (status != ER_OK) {NSLog(@"ERROR: Failed to connect bus. %@", [AJNStatus descriptionForStatusCode:status]);}
    
    status = [self.busAttachment addMatchRule:@"sessionless='t'"];
    if (status != ER_OK) {NSLog(@"ERROR: Unable to add match rule. %@", [AJNStatus descriptionForStatusCode:status]);}
}

- (void)buluMessageReceived:(NSString*)username type:(NSString*)type data:(NSString *)data from:(NSString*)sender onObjectPath:(NSString *)path forSession:(AJNSessionId)sessionId
{
    NSLog(@"username: %@, type: %@, data: %@, from: %@, path: %@, sessionId: %d", username, type, data, sender, path, sessionId);
    
    // Pass the signal to TimelineViewController
    UINavigationController* navController = [self.window.rootViewController childViewControllers][1];
    [[navController childViewControllers][0] handleBuluSignal:username type:type data:data];
}

- (void) readS3Credentials
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"credentials" ofType:@"txt"];
    NSString* fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    NSCharacterSet *newlineCharSet = [NSCharacterSet newlineCharacterSet];
    NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:newlineCharSet];
    self.s3Bucket = lines[0];
    self.s3AccessKeyId = lines[1];
    self.s3SecretAccessKey = lines[2];
}

@end
