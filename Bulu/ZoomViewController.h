//
//  ZoomViewController.h
//  Bulu
//
//  Created by apple on 13/2/20.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomViewController : UIViewController

@property (nonatomic, strong) NSNumber* pageIndex;
@property (nonatomic, strong) NSString* fileName;

+ (ZoomViewController*)zoomViewControllerForPageIndex:(NSUInteger)pageIndex
                                                 data:(NSArray*)data
                                 navigationController:(UINavigationController*)navController;

@end
