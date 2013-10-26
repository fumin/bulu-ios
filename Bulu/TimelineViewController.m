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

@interface TimelineViewController () <UICollectionViewDataSource, UIGestureRecognizerDelegate>
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
    
    // read past photos from disk
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError* err;
    NSArray* imageNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docDir error:&err];
    if (!self.data) {
        self.data = [[NSMutableArray alloc] init];
        for (NSString* name in imageNames) {
            [self.data insertObject:@{@"username": @"awaw", @"type": @"image_url", @"data": name} atIndex:0];
        }
    }
    
    // Signals in self.pendingData are the ones that we received even before our view is loaded.
    int len = [self.pendingData count];
    for (int i = 0; i != len; i++) {
        NSDictionary* obj = self.pendingData[i];
        [self handleBuluSignal:obj[@"username"] type:obj[@"type"] data:obj[@"data"]];
    }
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    [longPressGesture setDelegate:self];
    [self.collectionView addGestureRecognizer:longPressGesture];
    
    
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.collectionView.allowsMultipleSelection) {
        return NO;
    } else {
        return YES;
    }
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
    NSLog(@"self.data count: %d", [self.data count]);
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
    
    UIView *bgView = [[UIView alloc] init];
    [bgView setBackgroundColor:[UIColor greenColor]];
    cell.selectedBackgroundView = bgView;
    return cell;
}

- (void)longPressHandler:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    UINavigationController* navController = (UINavigationController*)[self parentViewController];
    if (navController.navigationBarHidden) {
        [navController setNavigationBarHidden:NO animated:NO];
        self.collectionView.allowsMultipleSelection = YES;
    } else {
        [navController setNavigationBarHidden:YES animated:NO];
        self.collectionView.allowsMultipleSelection = NO;
    }
}

- (IBAction)deleteItems:(id)sender {
    NSMutableIndexSet* successfullyDeleted = [[NSMutableIndexSet alloc] init];
    NSMutableArray* successfullyDeletedIndexPaths = [NSMutableArray arrayWithCapacity:0];
    
    NSArray* indexPaths = [self.collectionView indexPathsForSelectedItems];
    int len = [indexPaths count];
    for (int i = 0; i != len; i++) {
        NSIndexPath* indexPath = indexPaths[i];
        NSString* fileName = self.data[indexPath.row][@"data"];
        if ([[[BuluUtils alloc] init] deleteImageFromFileName:fileName]) {
            [successfullyDeleted addIndex:indexPath.row];
            [successfullyDeletedIndexPaths insertObject:indexPath atIndex:0];
        }
    }
    
    [self.collectionView performBatchUpdates:^{
        [self.data removeObjectsAtIndexes:successfullyDeleted];
        [self.collectionView deleteItemsAtIndexPaths:successfullyDeletedIndexPaths];
    } completion:nil];
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // [self.data insertObject] must be in the same thread as [collectionView insertItems]
                        // to avoid the exception NSInternalInconsistencyException
                        NSLog(@"starting insert: %d", [self.data count]);
                        [self.collectionView performBatchUpdates:^{
                            NSLog(@"starting insert 0000000: %d", [self.data count]);
                            [self.data insertObject:@{@"username": username, @"type": type, @"data": fileName} atIndex:0];
                            NSLog(@"starting insert 111111111: %d", [self.data count]);
                            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
                            NSLog(@"starting insert 22222222: %d", [self.data count]);
                        } completion:nil];
                    });
                }
            }
        });
    }
}

@end
