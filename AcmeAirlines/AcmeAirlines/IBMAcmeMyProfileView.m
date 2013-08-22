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

//  This class present the profile information of a user

#import "IBMAcmeMyProfileView.h"
#import "IBMAcmeConstant.h"
#import "IBMAcmeWebView.h"
#import <QuartzCore/QuartzCore.h>
#import "IBMConnectionsProfileService.h"
#import "IBMProfileListView.h"
#import "FBLog.h"
#import "IBMAcmeUtils.h"

@interface IBMAcmeMyProfileView ()

@property (strong, nonatomic) UIImage *profilePhoto;
@property (strong, nonatomic) UIPopoverController *popOverController;
@property (strong, nonatomic) NSMutableArray *listOfTitles;

@end

@implementation IBMAcmeMyProfileView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listOfTitles = [[NSMutableArray alloc] initWithObjects:
                         @"Email",
                         @"Phone Number",
                         @"Connections Profile",
                         @"Report-to Chain",
                         @"Same Manager",
                         @"People Managed",
                         nil];
    
    if (self.myProfile.displayName != nil)
        self.title = self.myProfile.displayName;
    
    // If thumbnail url is nil it is probably a not complete profile info, so go ahead and retrieve it.
    // This usually happens when we retrieve a community member which only has name and userid
    if (self.myProfile.thumbnailURL == nil) {
        UIAlertView *progressView = [IBMAcmeUtils showProgressBar];
        [self retrieveProfileWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self.tableView reloadData];
            }
            [progressView dismissWithClickedButtonIndex:100 animated:YES];
        }];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else if (section == 1)
        return 3;
    else
        return 3;
}

- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section
{
    if (section == 0)
        return 10;
    else
        return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
            
            [self addSubViewsToInfoCell:cell];
        }
        
        UILabel *titleLabel = (UILabel *) [cell.contentView viewWithTag:4];
        titleLabel.text = self.myProfile.title;
        UILabel *nameLabel = (UILabel *) [cell.contentView viewWithTag:5];
        nameLabel.text = self.myProfile.displayName;
        
        UIButton *editButton = (UIButton *) [cell.contentView viewWithTag:3];
        // Hide or show edit label
        if ([self.comingFrom isEqualToString:@"IBMViewController"]) {
            editButton.hidden = NO;
        } else {
            editButton.hidden = YES;
        }
        
        UIImageView *profilePictureView = (UIImageView *) [cell.contentView viewWithTag:1];
        profilePictureView.image = [UIImage imageNamed:@"profile_photo_default.png"];
        [IBMAcmeUtils downloadAndSetImage:profilePictureView url:self.myProfile.thumbnailURL];
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // Title label
            float textSize;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                textSize = TEXT_SIZE_IPAD_SMALL;
            } else {
                textSize = TEXT_SIZE_SMALL;
            }
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.tag = 1;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont boldSystemFontOfSize:textSize];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            // Conent label
            UILabel *contentLabel = [[UILabel alloc] init];
            contentLabel.tag = 2;
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
            contentLabel.adjustsFontSizeToFitWidth = YES;
            contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            [cell.contentView addSubview:titleLabel];
            [cell.contentView addSubview:contentLabel];
        }
        
        float textSizeTitle;
        float height;
        float contentWidth;
        float x;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textSizeTitle = TEXT_SIZE_IPAD_SMALL;;
            x = 10;
            height = 50;
            contentWidth = 270;
        } else {
            textSizeTitle = TEXT_SIZE_SMALL;
            x = 7;
            height = 30;
            contentWidth = 180;
        }
        
        NSString *text = [self.listOfTitles objectAtIndex:((indexPath.section - 1)*3 + indexPath.row)];
        UILabel *titleLabel = (UILabel *) [cell.contentView viewWithTag:1];
        UILabel *contentLabel = (UILabel *) [cell.contentView viewWithTag:2];
        
        // Remove old constraints
        for (NSLayoutConstraint *co in [cell.contentView constraints]) {
            if ([co.firstItem isEqual:titleLabel] || [co.firstItem isEqual:contentLabel]) {
                [cell.contentView removeConstraint:co];
            }
        }
        
        CGSize requiredSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:textSizeTitle]
                                                    constrainedToSize:CGSizeMake(1000, 1000)
                                                        lineBreakMode:NSLineBreakByTruncatingTail];
        
        // Add title label constraints
        NSLayoutConstraint *constraintLeftTitle = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:cell.contentView
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1
                                                                           constant:x];
        NSLayoutConstraint *constraintTopTitle = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:cell.contentView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0];
        NSLayoutConstraint *constraintWidthTitle = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:requiredSize.width];
        NSLayoutConstraint *constraintHeightTitle = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                                  constant:height];
        // Add content label constraints
        NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:contentLabel
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:titleLabel
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1
                                                                           constant:5];
        NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:contentLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:titleLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1
                                                                           constant:0];
        NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:contentLabel
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:contentWidth];
        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:contentLabel
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:height];
        [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintLeftTitle,
                                          constraintTopTitle,
                                          constraintWidthTitle,
                                          constraintHeightTitle,
                                          constraintLeft,
                                          constraintTop,
                                          constraintWidth,
                                          constraintHeight,
                                          nil]];
        
        titleLabel.text = text;
        
        if (indexPath.section == 1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            if (indexPath.row == 0) {
                contentLabel.text = [NSString stringWithFormat:@"(%@)", self.myProfile.email];
            } else if (indexPath.row == 1) {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                contentLabel.text = [NSString stringWithFormat:@"(%@)", self.myProfile.phoneNumber];
            } else if (indexPath.row == 2) {
                contentLabel.text = @"";
            }
        } else if (indexPath.section == 2) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            if (indexPath.row == 0) {
                contentLabel.text = @"";
            } else if (indexPath.row == 1) {
                contentLabel.text = @"";
            } else if (indexPath.row == 2) {
                contentLabel.text = @"";
            }
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (indexPath.section == 0)
            return 240;
        else
            return 60;
    } else {
        if (indexPath.section == 0)
            return 140;
        else
            return 40;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            // Email
            NSString *to = [NSString stringWithFormat:@"%@", self.myProfile.email];
            NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@",
                                                        [to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
            [[UIApplication sharedApplication] openURL:url];
        } else if (indexPath.row == 1) {
            // Phone
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                            message:@"This action will close Acme Airlines app and will open Phone app on your iPhone?"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Cancel", @"OK", nil];
            [alert show];
        } else if (indexPath.row == 2) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ibmscp://com.ibm.connections/profiles?email=%@", self.myProfile.email]];
            if ([[UIApplication sharedApplication] openURL:url] == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"You need IBM Connections' app installed for this action."
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self getReportToChain];
        } else if (indexPath.row == 1) {
            [self getSameManager];
        } else if (indexPath.row == 2) {
            [self getPeopleManaged];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helper methods image upload

/**
 This method is executed when a plus edit button on the profile picture is tapped
 This allows users to update his profile photo from the gallery
 */
-(void) editPhoto:(UIButton *) button {
    if (button.tag == 3) {
        [self uploadImageFromPhotoGalleryButton:button];
    }
}

/**
 This will present the picker controller to select image from the gallery
 */
- (void) uploadImageFromPhotoGalleryButton:(UIButton *) button {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = (id) self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popOverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popOverController.delegate = (id) self;
        [self.popOverController presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:picker animated:YES completion:^(void) {
            
        }];
    }
}

/**
 Image is selected and returned in this method
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
	
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *newImage = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
    NSData *content = UIImagePNGRepresentation(newImage);
    [self uploadProfilePhotoWithContent:content];
}

/**
 Scale image to the given newSize
 @param newSize: new size of the image
 */
- (UIImage *) imageWithImage:(UIImage*) image scaledToSize:(CGSize) newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 This methods handles the upload process of the photo
 */
- (void) uploadProfilePhotoWithContent:(NSData *) content {
    IBMConnectionsProfileService *profileService = [[IBMConnectionsProfileService alloc] init];
    [profileService uploadProfilePhotoForUserId:self.myProfile.userId data:content contentType:@"image/png" success:^(BOOL success) {
        [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
    }];
}

/**
 This methods updates the profile photo and let user knows about the result
 */
- (void) updateUI {
    self.myProfile = [IBMAcmeUtils getMyProfileForce:YES];
    [self.popOverController dismissPopoverAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:[NSString stringWithFormat:@"Your photo has been changed"]
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Helper methods --others--

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
    if (buttonIndex == 1) {
        NSString *phoneNumber = [@"tel://" stringByAppendingString:self.myProfile.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

/**
 Retrieve profile to complete missing information
 */
- (void) retrieveProfileWithCompletionHandler:(void (^)(BOOL)) completionHandler {
    IBMConnectionsProfileService *profileService = [[IBMConnectionsProfileService alloc] init];
    [profileService getProfile:self.myProfile.userId success:^(IBMConnectionsProfile *profile) {
        if (profile != nil) {
            self.myProfile = profile;
            self.title = self.myProfile.displayName;
            completionHandler(YES);
        }
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
        
        completionHandler(NO);
    }];
}

/**
 Push IBMProfileListView to the navigation controller
 */
- (void) openProfileListViewWithList:(NSMutableArray *) list {
    
    IBMProfileListView *listView = [[IBMProfileListView alloc] init];
    listView.listOfProfiles = list;
    [self.navigationController pushViewController:listView animated:YES];
}

/**
 This method gets the report to chain and open a view to list them
 */
- (void) getReportToChain {
    
    UIAlertView *progressView = [IBMAcmeUtils showProgressBar];
    IBMConnectionsProfileService *profileService = [[IBMConnectionsProfileService alloc] init];
    [profileService getReportToChainWithUserId:self.myProfile.email parameters:nil success:^(NSMutableArray *list) {
        if (list != nil)
            [self openProfileListViewWithList:list];
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
    }];
}

/**
 Get the profiles with the same manager as the current person
 */
- (void) getSameManager {
    UIAlertView *progressView = [IBMAcmeUtils showProgressBar];
    IBMConnectionsProfileService *profileService = [[IBMConnectionsProfileService alloc] init];
    [profileService getReportToChainWithUserId:self.myProfile.email parameters:nil success:^(NSMutableArray *list) {
        if (list != nil && [list count] >= 2) {
            IBMConnectionsProfile *manager = [list objectAtIndex:1];
            IBMConnectionsProfileService *profileService_ = [[IBMConnectionsProfileService alloc] init];
            [profileService_ getDirectReportsWithUserId:manager.userId parameters:nil success:^(NSMutableArray *list) {
                if (list != nil) {
                    [self openProfileListViewWithList:list];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ doesn't have a person reporting to the same manager", self.myProfile.displayName] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                }
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
            } failure:^(NSError *error) {
                if (IS_DEBUGGING)
                    [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
            }];
        } else {
            [progressView dismissWithClickedButtonIndex:100 animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ doesn't have a manager", self.myProfile.displayName] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
    }];
}

/**
 Get managed persons' profile
 */
- (void) getPeopleManaged {
    
    UIAlertView *progressView = [IBMAcmeUtils showProgressBar];
    IBMConnectionsProfileService *profileService = [[IBMConnectionsProfileService alloc] init];
    [profileService getDirectReportsWithUserId:self.myProfile.userId parameters:nil success:^(NSMutableArray *list) {
        if (list != nil) {
            [self openProfileListViewWithList:list];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ doesn't manage any person", self.myProfile.displayName] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
    }];
    
}

/**
 This method add all subviews to the user's info cell (section 0)
 */
- (void) addSubViewsToInfoCell:(UITableViewCell *) cell {
    float height;
    float width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = 160;
        height = 160;
    } else {
        width = 80;
        height = 80;
    }
    
    UIImageView *profilePictureView = [[UIImageView alloc] init];
    profilePictureView.tag = 1;
    profilePictureView.layer.masksToBounds = YES;
    profilePictureView.layer.cornerRadius = 5;
    profilePictureView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:profilePictureView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:width];
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:profilePictureView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:height];
    NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:profilePictureView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:cell.contentView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0];
    NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:profilePictureView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:cell.contentView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:-20];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintWidth, constraintHeight, constraintX, constraintY, nil]];
    
    // Add edit button
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editPhoto:) forControlEvents:UIControlEventTouchUpInside];
    editButton.tag = 3;
    editButton.hidden = YES;
    editButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = 40;
        height = 40;
    } else {
        width = 20;
        height = 20;
    }
    
    NSLayoutConstraint *constraintWidthButton = [NSLayoutConstraint constraintWithItem:editButton
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1
                                                                              constant:width];
    NSLayoutConstraint *constraintHeightButton = [NSLayoutConstraint constraintWithItem:editButton
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1
                                                                               constant:height];
    NSLayoutConstraint *constraintBottomButton = [NSLayoutConstraint constraintWithItem:editButton
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:profilePictureView
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
    NSLayoutConstraint *constraintRightButton = [NSLayoutConstraint constraintWithItem:editButton
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:profilePictureView
                                                                             attribute:NSLayoutAttributeRight
                                                                            multiplier:1
                                                                              constant:0];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintWidthButton, constraintHeightButton, constraintBottomButton, constraintRightButton, nil]];
    
    // Name label
    float textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textSize = TEXT_SIZE_IPAD;
        width = 280;
        height = 30;
    } else {
        textSize = TEXT_SIZE;
        width = 280;
        height = 20;
    }
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont boldSystemFontOfSize:textSize];
    nameLabel.tag = 5;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintWidthNameLabel = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                                attribute:NSLayoutAttributeWidth
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1
                                                                                 constant:width];
    NSLayoutConstraint *constraintHeightNameLabel = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1
                                                                                  constant:height];
    NSLayoutConstraint *constraintTopNameLabel = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:profilePictureView
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
    NSLayoutConstraint *constraintXNameLabel = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:profilePictureView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1
                                                                             constant:0];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintWidthNameLabel, constraintHeightNameLabel, constraintTopNameLabel, constraintXNameLabel, nil]];
    
    // Title label
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = 280;
        height = 30;
    } else {
        width = 280;
        height = 20;
    }
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    titleLabel.tag = 4;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintWidthTitleLabel = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1
                                                                                  constant:width];
    NSLayoutConstraint *constraintHeightTitleLabel = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1
                                                                                   constant:height];
    NSLayoutConstraint *constraintTopTitleLabel = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nameLabel
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1
                                                                                constant:0];
    NSLayoutConstraint *constraintXTitleLabel = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nameLabel
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1
                                                                              constant:0];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintWidthTitleLabel, constraintHeightTitleLabel, constraintTopTitleLabel, constraintXTitleLabel, nil]];
    
    [cell.contentView addSubview:profilePictureView];
    [cell.contentView addSubview:editButton];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:titleLabel];
    
}



@end
