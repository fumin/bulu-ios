//
//  FullScreenPhotoViewController.m
//  Bulu
//
//  Created by apple on 13/2/20.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import "FullScreenPhotoViewController.h"
#import "ZoomViewController.h"
#import "BuluUtils.h"

@interface FullScreenPhotoViewController ()

@end

@implementation FullScreenPhotoViewController

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
    self.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    ZoomViewController* zvc = [ZoomViewController zoomViewControllerForPageIndex:[self.initialPageIndex integerValue]  data:self.data navigationController:self.navController];
    [self setViewControllers:@[zvc] direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
      viewControllerBeforeViewController:(ZoomViewController *)vc
{
    NSUInteger index = [vc.pageIndex integerValue];
    return [ZoomViewController zoomViewControllerForPageIndex:(index - 1) data:self.data navigationController:self.navController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc
       viewControllerAfterViewController:(ZoomViewController *)vc
{
    NSUInteger index = [vc.pageIndex integerValue];
    return [ZoomViewController zoomViewControllerForPageIndex:(index + 1) data:self.data navigationController:self.navController];
}

- (IBAction)saveImageToLibrary:(id)sender {
    ZoomViewController* zvc = (ZoomViewController*)self.viewControllers[0];
    UIImage* imageToSave = [[[BuluUtils alloc] init] originalImageFromFileName:zvc.fileName];
    UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
}

@end
