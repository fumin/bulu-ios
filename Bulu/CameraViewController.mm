//
//  ViewController.m
//  Bulu
//
//  Created by apple on 13/2/16.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "CameraViewController.h"
#import "AppDelegate.h"
#import "NSString_RandomStr.h"
#import "Utils.h"
#import "BuluUtils.h"

@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [((UITabBarController*)[self parentViewController]) setSelectedIndex:1];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        //UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                NSString *filename = [NSString stringFromRandomStrWithLength:8];
                if ([[[Utils alloc] init] upload_to_s3:imageToSave underName:filename]) {
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
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
    }
    
    [self imagePickerControllerDidCancel:picker];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

@end
