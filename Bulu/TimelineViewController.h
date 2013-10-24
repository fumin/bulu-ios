//
//  TimelineViewController.h
//  Bulu
//
//  Created by apple on 13/2/16.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineViewController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *data;

- (void)handleBuluSignal:(NSString*)username type:(NSString*)type data:(NSString*)data;

@end
