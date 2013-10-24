//
//  ZoomViewController.m
//  Bulu
//
//  Created by apple on 13/2/20.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"

#import "ZoomViewController.h"
#import "ImageScrollView.h"
#import "BuluUtils.h"

@interface ZoomViewController ()

@property (nonatomic, weak) UINavigationController* navController;

@property (nonatomic, strong) UIGestureRecognizer* originalRecognizer;

@end

@implementation ZoomViewController

+ (ZoomViewController*)zoomViewControllerForPageIndex:(NSUInteger)pageIndex
                                                 data:(NSArray*)data
                                 navigationController:(UINavigationController *)navController
{
    if (pageIndex < [data count]) {
        ZoomViewController* zvc = [[ZoomViewController alloc] init];
        if (zvc) {
            zvc.navController = navController;
            zvc.pageIndex = [NSNumber numberWithInteger:pageIndex];
            zvc.fileName = data[pageIndex][@"data"];

            return zvc;
        }
    }
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    scrollView.img = [[[BuluUtils alloc] init] fullScreenImageFromFileName:self.fileName];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Replace pinch gesture
    for (UIGestureRecognizer* gestureRec in [scrollView gestureRecognizers]) {
        if ([gestureRec isKindOfClass:[UIPinchGestureRecognizer class]]) {
            self.originalRecognizer = gestureRec;
            [scrollView removeGestureRecognizer:gestureRec];
        }
    }
    UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [scrollView addGestureRecognizer:pinchRecognizer];
    
    // Set up single tap gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [scrollView addGestureRecognizer:tapRecognizer];
    
    self.view = scrollView;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    ((ImageScrollView*)self.view).img = [[[BuluUtils alloc] init] originalImageFromFileName:self.fileName];
    for (UIGestureRecognizer* gestureRec in [self.view gestureRecognizers]) {
        if ([gestureRec isKindOfClass:[UIPinchGestureRecognizer class]]) {
            [self.view removeGestureRecognizer:gestureRec];
        }
    }
    [self.view addGestureRecognizer:self.originalRecognizer];
}

- (void)respondToTapGesture:(UITapGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.navController.navigationBarHidden) {
            [self.navController setNavigationBarHidden:NO animated:YES];
            [self.navController setToolbarHidden:NO animated:YES];
        } else {
            [self.navController setNavigationBarHidden:YES animated:YES];
            [self.navController setToolbarHidden:YES animated:YES];
        }
    }
}

@end
