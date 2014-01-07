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

//  This class is used to generate and post new blog post

#import "ComposeUpdate.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "SBTAcmeUtils.h"
#import "IBMConnectionsFileService.h"
#import "IBMConnectionsProfile.h"
#import "FBLog.h"

#define TEXT_SIZE 2000

@interface ComposeUpdate ()

@property (nonatomic, strong) UIPopoverController *popController;
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UILabel *remainingLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *actIndicator;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UIImageView *selectedImageView;
@property (nonatomic, strong) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, strong) NSString *textToSend;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation ComposeUpdate

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Release any cached data, images, etc that aren't in use.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.tintColor = [UIColor colorWithRed:90.0/255
                                                   green:91.0/255
                                                    blue:71.0/255
                                                   alpha:1];
    self.selectedImageView.hidden = YES;
    self.selectedImageView.layer.masksToBounds = YES;
    self.selectedImageView.layer.cornerRadius = 5;
    
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.cornerRadius = 10;
    self.textView.layer.borderWidth = 1;
    [self.textView becomeFirstResponder];
	
	UIBarButtonItem *doneItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(submit)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.navItem.rightBarButtonItem = doneItem1;
    self.navItem.leftBarButtonItem = cancel;
    self.remainingLabel.text = [NSString stringWithFormat:@"%d", TEXT_SIZE];
    
    // If it is a comment then hide the photo button
    if (self.entry != nil) {
        [self.takePhotoButton setHidden:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    
}

- (void) textViewDidChange:(UITextView *)textView {
    self.textToSend = self.textView.text;
    self.remainingLabel.text = [NSString stringWithFormat:@"%d", TEXT_SIZE - textView.text.length];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        return FALSE;
    }
    
    return TRUE;
}

- (void) setTitleOfViewWithString:(NSString *) title {
    self.navItem.title = title;
}

/*
 Called when photo upload is initiated by user. Presents an option of either take a photo or select from the library
 */
- (IBAction) addImage:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:(id)self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take a photo", @"Choose from library",nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)sender clickedButtonAtIndex:(int)index
{
    if (index == 0) {//user selected take a photo
        if (IS_DEBUGGING)
            [FBLog log:@"Taking a photo" from:self];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
            UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
            cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            //cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            cameraUI.delegate = (id) self;
            [self presentViewController:cameraUI animated:YES completion:^(void) {
                
            }];
            
        } else {
            if (IS_DEBUGGING)
                [FBLog log:@"Camera is not available in this device" from:self];
        }
        
    } else if (index == 1) {// user selected to choose from the photo library
        if (IS_DEBUGGING)
            [FBLog log:@"Choose from library" from:self];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == YES) {
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            // Hides the controls for moving & scaling pictures, or for
            // trimming movies. To instead show the controls, use YES.
            // mediaUI.allowsEditing = YES;
            mediaUI.delegate = (id) self;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
                self.popController = [[UIPopoverController alloc] initWithContentViewController:mediaUI];
                self.popController.delegate = (id) self;
                [self.popController presentPopoverFromRect:self.takePhotoButton.bounds inView:self.takePhotoButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [self presentViewController:mediaUI animated:YES completion:^(void) {
                    
                }];
            }
            
        } else {
            if (IS_DEBUGGING)
                [FBLog log:@"Photo album is not available in this device" from:self];
        }
    }
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [self dismissViewControllerAnimated:YES completion:^(void) {
                
            }];
        } else {
            [self.popController dismissPopoverAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:^(void) {
            
        }];
    }
    
    self.textView.text = self.textToSend;
}

/*
 For responding to the user accepting a newly-captured picture
 */
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    self.textView.text = self.textToSend;//sometimes textview text disappear to due to high memory overhead so this one et it back
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *imageToSave;
    
    // Handle a still image capture
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage]) {
        self.selectedImage = nil;
        
        self.view.userInteractionEnabled = NO;
        [self.actIndicator startAnimating];
        self.statusLabel.text = @"Saving...";
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                [self dismissViewControllerAnimated:YES completion:^(void) {
                    
                }];
            } else {
                [self.popController dismissPopoverAnimated:YES];
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:^(void) {
                
            }];
        }
        
        [NSThread detachNewThreadSelector:@selector(useImage:) toTarget:self withObject:originalImage];
        
        if (NO && [info objectForKey:@"UIImagePickerControllerReferenceURL"] == nil) {
            // Save the new image (original or edited) to the Camera Roll
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
        } else {
            //NSLog(@"Here is the url: %@", [info objectForKey:@"UIImagePickerControllerReferenceURL"]);
        }
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                [self dismissViewControllerAnimated:YES completion:^(void) {
                    
                }];
            } else {
                [self.popController dismissPopoverAnimated:YES];
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:^(void) {
                
            }];
        }
    }
}

/*
 Rescale the image
 */
- (void) useImage:(UIImage *) image {
    image = [self changeImageOrientationWithImage:image];
    
    NSData *imageData;
    BOOL shouldCompress = NO;
    if (shouldCompress) {
        //Resize the image to maxFileSize
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 1000*500;
        imageData = UIImageJPEGRepresentation(image, compression);
        while ([imageData length] > maxFileSize && compression > maxCompression) {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        //imageName = @"iuploaded.jpeg";
        //contentType = @"image/jpeg";
        
        UIImage *newImage = [UIImage imageWithData:imageData];
        // Show image on the main thread, because it is an UI operation
        [self performSelectorOnMainThread:@selector(showImage:) withObject:newImage waitUntilDone:NO];
        
    } else {
        //calculate the right width and height
        float width, height;
        float maxSize = 540;
        
        if (image.size.width > image.size.height) {
            if (image.size.width > maxSize) {
                float ratio = image.size.width/maxSize;
                height = image.size.height/ratio;
                width = maxSize;
            } else {
                height = image.size.height;
                width = image.size.width;
            }
        } else {
            if (image.size.height > maxSize) {
                float ratio = image.size.height/maxSize;
                width = image.size.width/ratio;
                height = maxSize;
            } else {
                height = image.size.height;
                width = image.size.width;
            }
        }
        
        CGSize newSize = CGSizeMake(width, height);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Show image on the main thread, because it is an UI operation
        [self performSelectorOnMainThread:@selector(showImage:) withObject:newImage waitUntilDone:NO];
    }
    
    [self performSelectorOnMainThread:@selector(clearThingsUp) withObject:nil waitUntilDone:NO];
}

- (void) clearThingsUp {
    [self.actIndicator stopAnimating];
    self.view.userInteractionEnabled = YES;
    self.statusLabel.text = @"";
}

/*
 Show image to user
 */
- (void) showImage:(UIImage *) img {
    self.selectedImage = img;
    self.selectedImageView.hidden = NO;
    self.selectedImageView.image = self.selectedImage;
}

- (void) hideTakePhotoButton:(BOOL) hide {
    self.takePhotoButton.hidden = hide;
}

- (UIImage *) changeImageOrientationWithImage:(UIImage *) image {
    if (image.imageOrientation == UIImageOrientationUp) 
        return image; 
    else {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawInRect:(CGRect){0, 0, image.size}];
        UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
}

/*
 Dismiss the current compose update view
 */
- (void) cancel {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
}

/*
 Initiate the uploading process
 */
- (void) submit {
    NSString *text = self.textToSend;
    if (text.length > TEXT_SIZE) {
        [self alert:@"Text Length" message:[NSString stringWithFormat:@"You can write at most %d characters!", TEXT_SIZE]];
    } else if (text.length == 0) {
        [self alert:@"Text Length" message:[NSString stringWithFormat:@"Text cannot be empty!"]];
    }  else {
        if (self.selectedImage != nil) {
            [self.actIndicator startAnimating];
            self.statusLabel.text = @"Uploading...";
            self.view.userInteractionEnabled = NO;
            
            //perform sending operation in background thread
            [NSThread detachNewThreadSelector:@selector(sendData:) toTarget:self withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.selectedImage, @"image", text, @"text", nil]];
        } else {
            if (text.length > 0) {
                [self.actIndicator startAnimating];
                self.statusLabel.text = @"Uploading...";
                self.view.userInteractionEnabled = NO;
                
                IBMConnectionsActivityStreamService *actStrSrv = [[IBMConnectionsActivityStreamService alloc] init];
                NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                text, @"content",
                                                nil];
                if (self.entry == nil) {
                    // Status update
                    NSString *communityUuidFull = [NSString stringWithFormat:@"urn:lsid:lconn.ibm.com:communities.community:%@", self.community.communityUuid];
                    [actStrSrv postMBEntryUserType:communityUuidFull groupType:@"@all" appType:nil payload:payload success:^(id result) {
                        [self performSelectorOnMainThread:@selector(completeUploadOption:) withObject:@"text" waitUntilDone:YES];
                    } failure:^(NSError *error) {
                        if (IS_DEBUGGING)
                            [FBLog log:[error description] from:self];
                        
                        [self performSelectorOnMainThread:@selector(completeUploadOption:) withObject:@"error" waitUntilDone:YES];
                    }];
                } else {
                    // Comment
                    NSString *commentIdFull = [NSString stringWithFormat:@"%@/comments", self.entry.eId];
                    [actStrSrv postMBEntryUserType:@"@all" groupType:@"@all" appType:commentIdFull payload:payload success:^(id result) {
                        [self performSelectorOnMainThread:@selector(completeUploadOption:) withObject:@"comment" waitUntilDone:YES];
                    } failure:^(NSError *error) {
                        if (IS_DEBUGGING)
                            [FBLog log:[error description] from:self];
                        
                        [self performSelectorOnMainThread:@selector(completeUploadOption:) withObject:@"error" waitUntilDone:YES];
                    }];
                }
            }
        }
    }
}

- (void) sendData:(NSDictionary *) dict {
    NSData *imageData = UIImagePNGRepresentation([dict objectForKey:@"image"]);
    if (imageData == nil) {
        return;
    }
    
    NSString *text = [dict objectForKey:@"text"];
    NSString *contentType = @"image/png";
    
    NSString *fileName = [NSString stringWithFormat:@"%@.png", [[NSDate date] description]];
    IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] initWithEndPointName:@"connections"];
    [fS uploadMultiPartFileWithContent:imageData fileName:fileName mimeType:contentType fromUserType:@"communitylibrary" groupType:self.community.communityUuid appType:@"feed" success:^(id result) {
        // Now construct the payload for posting an image along with text
        NSMutableDictionary *jsonPayload = [self constructPayload:result text:text];
        
        IBMConnectionsActivityStreamService *actStrSrv = [[IBMConnectionsActivityStreamService alloc] init];
        NSString *communityUuidFull = [NSString stringWithFormat:@"urn:lsid:lconn.ibm.com:communities.community:%@", self.community.communityUuid];
        [actStrSrv postMBEntryUserType:communityUuidFull groupType:@"@all" appType:nil payload:jsonPayload success:^(id result) {
            [self performSelectorOnMainThread:@selector(completeUploadOption:) withObject:@"text" waitUntilDone:YES];
        } failure:^(NSError *error) {
            if (IS_DEBUGGING)
                [FBLog log:[error description] from:self];
            
            [self performSelectorOnMainThread:@selector(completeUploadOption:) withObject:@"error" waitUntilDone:YES];
        }];
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
        
        [self performSelectorOnMainThread:@selector(completeUploadOption:) withObject:@"error" waitUntilDone:YES];
    }];
}

- (void) completeUploadOption:(NSString *) option {
    self.view.userInteractionEnabled = YES;
    [self.actIndicator stopAnimating];
    self.statusLabel.text = @"";
    
    if ([option isEqualToString:@"text"] || [option isEqualToString:@"comment"]) {
        if ([self.delegateViewController respondsToSelector:@selector(postStatus:)]) {
            NSDictionary *userDict = nil;
            if ([option isEqualToString:@"comment"]) {
                userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"message", @"comment is added", nil];
            }
            
            [self dismissViewControllerAnimated:YES completion:^(void) {
                [self.delegateViewController performSelector:@selector(postStatus:) withObject:userDict];
            }];
        }
    } else if ([option isEqualToString:@"error"]) {
        
    }
}

- (void) alert:(NSString *) title message:(NSString *) message {
	UIAlertView* dialog = [[UIAlertView alloc] init];
    dialog.tag = 22;
	[dialog setDelegate:self];
	[dialog setTitle:title];
	[dialog setMessage:message];
	[dialog addButtonWithTitle:@"OK"];
	[dialog show];
}

/**
 This method wire image information to the payload along with the text
 @param result: result dictionary of the file upload
 */
- (NSMutableDictionary *) constructPayload:(NSMutableDictionary *) result text:(NSString *) text {
    
    // Extract the id of the image
    NSString *id_;
    NSString *idPattern = @"urn:lsid:ibm.com:td:";
    if ([[result objectForKey:@"id"] hasPrefix:idPattern]) {
        id_ = [[result valueForKey:@"id"] substringFromIndex:[idPattern length]];
    } else {
        id_ = [result objectForKey:@"id"];
    }
    NSString *urlLink = @"";
    NSArray *links = [result objectForKey:@"links"];
    for (NSDictionary *dict in links) {
        if ([[dict objectForKey:@"rel"] isEqualToString:@"enclosure"]) {
            urlLink = [dict objectForKey:@"href"];
        }
    }
    
    // Manually constructing the thumbnail url, may need to change this.
    NSString *thumbnailUrl = @"";
    if (urlLink != nil) {
        NSArray *parts = [urlLink componentsSeparatedByString:@"/"];
        for (NSString *part in parts) {
            if (![part isEqualToString:@"media"])
                thumbnailUrl = [thumbnailUrl stringByAppendingFormat:@"%@/", part];
            else {
                thumbnailUrl = [thumbnailUrl stringByAppendingFormat:@"thumbnail"];
                break;
            }
        }
    }
    
    // Now construct the payload
    IBMConnectionsProfile *myProfile = [SBTAcmeUtils getMyProfileForce:NO];
    NSDictionary *author = [NSDictionary dictionaryWithObjectsAndKeys:
                            myProfile.userId, @"id",
                            nil];
    NSDictionary *image = [NSDictionary dictionaryWithObjectsAndKeys:
                           thumbnailUrl, @"url",
                           nil];
    NSDictionary *attachmentObj = [NSDictionary dictionaryWithObjectsAndKeys:
                                   id_, @"id",
                                   [result objectForKey:@"title"], @"displayName",
                                   author, @"author",
                                   image, @"image",
                                   urlLink, @"url",
                                   [result objectForKey:@"summary"], @"summary",
                                   [result objectForKey:@"published"], @"published",
                                   nil];
    NSArray *attachments = [NSArray arrayWithObject:attachmentObj];
    NSMutableDictionary *jsonPayload = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        attachments, @"attachments",
                                        text, @"content",
                                        nil];
    
    return jsonPayload;
}

#pragma mark - UIAlertView delegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 22) {
        if (buttonIndex == 0) {
            [self dismissViewControllerAnimated:YES completion:^(void) {
                
            }];
        }
    }
}

@end
