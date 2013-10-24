//
//  TimelineViewController.m
//  Bulu
//
//  Created by apple on 13/2/16.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import "TimelineViewController.h"

#import "MessageCell.h"
#import "FullScreenPhotoViewController.h"
#import "BuluUtils.h"

@interface TimelineViewController () <UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray* pendingData;
@end

@implementation TimelineViewController

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
    if (!self.data) {
        self.data = [NSMutableArray arrayWithCapacity:0];
    }
    
    // Signals in self.pendingData are the ones that we received even before our view is loaded.
    int len = [self.pendingData count];
    for (int i = 0; i != len; i++) {
        NSDictionary* obj = self.pendingData[i];
        [self handleBuluSignal:obj[@"username"] type:obj[@"type"] data:obj[@"data"]];
    }
    
    // Some testing data
    /*for (NSString* s in @[@"LeggyFrog.jpg", @"CuriousFrog.jpg", @"PeeringFrog.jpg"]) {
        NSString *path = [[[BuluUtils alloc] init] digestedDiskPath:s];
        [self.data insertObject:@{@"username": @"test", @"type": @"image_url", @"data":s} atIndex:0];
        NSData* rawBytes = UIImageJPEGRepresentation([UIImage imageNamed:s], 0.5);
        [rawBytes writeToFile:path atomically:YES];
    }*/
}

- (void)viewWillAppear:(BOOL)animated
{
    [((UINavigationController*)[self parentViewController]) setNavigationBarHidden:YES animated:NO];
    [((UINavigationController*)[self parentViewController]) setToolbarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FullScreenPhotoViewController* vc = (FullScreenPhotoViewController*)segue.destinationViewController;
    vc.data = self.data;
    NSIndexPath* selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
    vc.initialPageIndex = [NSNumber numberWithInteger:selectedIndexPath.row];
    vc.navController = (UINavigationController*)[self parentViewController];
    vc.hidesBottomBarWhenPushed = YES;
}

// UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = [self.collectionView
                                  dequeueReusableCellWithReuseIdentifier:@"MessageCell"
                                  forIndexPath:indexPath];
    
    NSString* fileName = self.data[indexPath.item][@"data"];
    cell.img.image = [[[BuluUtils alloc] init] thumbnailFromFileName:fileName];
    cell.text.text = self.data[indexPath.item][@"username"];
    return cell;
}

- (void)handleBuluSignal:(NSString*)username type:(NSString*)type data:(NSString*)data
{
    // Sometimes, we receive a signal even before the view is loaded.
    // Handling these signal immediately by calling [self.collectionView insertItemsAtIndexPaths] results in NSInternalInconsistencyException being raised.
    //
    // Therefore, temporarily store these signals somewhere and handle them later.
    if (!self.isViewLoaded) {
        if (!self.pendingData) {
            self.pendingData = [NSMutableArray arrayWithCapacity:0];
        }
        [self.pendingData insertObject:@{@"username": username, @"type": type, @"data": data} atIndex:0];
        return;
    }
    
    if ([type isEqualToString:@"image_url"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:data]];
                if (imgData) {
                    UIImage* img = [UIImage imageWithData:imgData];
                    NSString* fileName = [[[BuluUtils alloc] init] saveImageAsThumbnailAndOriginal:img];
                    [self.data insertObject:@{@"username": username, @"type": type, @"data": fileName} atIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
                    });
                }
            }
        });
    }
}

@end
