//
//  FullScreenPhotoViewController.h
//  Bulu
//
//  Created by apple on 13/2/20.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenPhotoViewController : UIPageViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) NSNumber* initialPageIndex; // assigned by TimelineViewController
@property (nonatomic, weak) NSMutableArray* data;
@property (nonatomic, weak) UINavigationController* navController;
- (IBAction)saveImageToLibrary:(id)sender;

@end
