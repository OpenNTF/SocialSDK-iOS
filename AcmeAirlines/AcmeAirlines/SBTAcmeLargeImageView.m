/*
 * © Copyright IBM Corp. 2013
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

//  Used to show image in full view

#import "IBMAcmeLargeImageView.h"
#import "ComposeUpdate.h"
#import "IBMAcmeUtils.h"
#import "UIImageView+AFNetworking.h"
#import "FBLog.h"

#define ZOOM_STEP 1.5

@implementation IBMAcmeLargeImageView

@synthesize photoView, scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isNavHidden = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.scrollView.bouncesZoom = YES;  
    self.scrollView.clipsToBounds = YES;
    self.scrollView.contentSize = [photoView frame].size;
    [self.scrollView setMinimumZoomScale:1.0];
    [self.scrollView setMaximumZoomScale:6.0];
    
    // add gesture recognizers to the image view  
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];  
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];  
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];  
    
    [doubleTap setNumberOfTapsRequired:2];  
    [twoFingerTap setNumberOfTouchesRequired:2];  
    
    [self.photoView addGestureRecognizer:singleTap];  
    [self.photoView addGestureRecognizer:doubleTap];  
    [self.photoView addGestureRecognizer:twoFingerTap];
    
    [self downloadAndSetImage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoView;
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    [self dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // zoom
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // zoom out
}

#pragma mark Utility methods

- (void) downloadAndSetImage {
    __block IBMAcmeLargeImageView *largeImageView = self;
    __block UIImageView *imageView = self.photoView;
    UIAlertView *progressView = [IBMAcmeUtils showProgressBar];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30];
    [self.photoView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"placeholder_image.png"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [progressView dismissWithClickedButtonIndex:100 animated:YES];
                                       imageView.image = image;
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       if (IS_DEBUGGING)
                                           [FBLog log:[error description] from:largeImageView];
                                       
                                       [progressView dismissWithClickedButtonIndex:100 animated:YES];
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to download image" delegate:largeImageView cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                       [alert show];
                                   }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self cancel];
    }
}

- (void) cancel {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
}

@end
