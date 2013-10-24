//
//  LibraryViewController.m
//  Bulu
//
//  Created by apple on 13/2/21.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "LibraryViewController.h"
#import "AppDelegate.h"
#import "NSString_RandomStr.h"
#import "Utils.h"
#import "BuluUtils.h"

@interface LibraryViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation LibraryViewController

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

- (void)viewDidAppear:(BOOL)animated
{
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [((UITabBarController*)[self parentViewController]) setSelectedIndex:1];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        // Do something with imageToUse
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                NSString *filename = [NSString stringFromRandomStrWithLength:8];
                if ([[[Utils alloc] init] upload_to_s3:imageToUse underName:filename]) {
                    AppDelegate* d = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    if (d.messageSignalHandlerImpl) {
                        NSString* remoteURL = [NSString stringWithFormat:@"http://d1a7rh4nd2ow65.cloudfront.net/expires_in_days/7/bulu/%@.jpg", filename];
                        NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
                        const char* cusername = [username cStringUsingEncoding:[NSString defaultCStringEncoding]];
                        d.messageSignalHandlerImpl->SendBuluSignal(cusername, "image_url",
                                                                   [remoteURL cStringUsingEncoding:[NSString defaultCStringEncoding]], 0);
                    }
                }
            }
        });
    }
    
    // Handle a movied picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        //NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        // Do something with the picked movie available at moviePath
    }
    
    [self imagePickerControllerDidCancel:picker];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

@end
