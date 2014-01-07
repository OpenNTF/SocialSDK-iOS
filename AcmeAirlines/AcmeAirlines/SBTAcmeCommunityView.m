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

//  This is a controller class to show information about the community including basic info and status updates

#import "SBTAcmeCommunityView.h"
#import "IBMConnectionsCommunityService.h"
#import "IBMAcmeConstant.h"
#import "IBMConnectionsActivityStreamService.h"
#import <QuartzCore/QuartzCore.h>
#import "SBTAcmeStatusUpdateView.h"
#import "SBTAcmeUtils.h"
#import "LikeButton.h"
#import "ComposeUpdate.h"
#import "SBTProfileListView.h"
#import "FBLog.h"
#import "SBTAcmeBookmarksView.h"

@interface SBTAcmeCommunityView ()

@property (strong, nonatomic) IBMConnectionsCommunity *community;
@property (strong, nonatomic) NSMutableArray *listOfMembers;
@property (strong, nonatomic) NSMutableArray *listOfUpdates;
@property (strong, nonatomic) NSNumber *joinLeaveInProgress;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UIBarButtonItem *addPostItem;

@end

@implementation SBTAcmeCommunityView

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

    self.state = @"info";
    self.addPostItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPost)];
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Lets refresh the data if anything changes when user drills to the other views
    if (self.isStatusChanged != nil && [self.isStatusChanged boolValue] == YES) {
        [self showUpdatesWithAlertMessage:nil];
        self.isStatusChanged = nil;
    }
    
    // Here we need to reload the data in table view in case the orientation changed
    [self performSelector:@selector(findVisibleCellsAndUpdate) withObject:nil afterDelay:0.2];
}

- (void) findVisibleCellsAndUpdate {
    NSArray* visibleCells = [self.tableView indexPathsForVisibleRows];
    [self performSelectorOnMainThread:@selector(rotate:) withObject:visibleCells waitUntilDone:NO];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void) rotate:(NSArray *) visibleCells {
    
    [self.tableView reloadRowsAtIndexPaths:visibleCells withRowAnimation:UITableViewRowAnimationFade];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSArray* visibleCells = [self.tableView indexPathsForVisibleRows];
    [self.tableView reloadRowsAtIndexPaths:visibleCells withRowAnimation:UITableViewRowAnimationAutomatic];
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
    if ([self.state isEqualToString:@"info"]) {
        return 2;
    } else {
        return 1 + [self.listOfUpdates count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        if ([self.state isEqualToString:@"info"])
            return 5;
        else {
            return 1;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    // Option (updates or info) segmented control
    if (section == 0) {
        NSInteger width;
        NSInteger height;
        CGRect viewFrame;
        CGRect windowBounds = [[UIScreen mainScreen] bounds];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            viewFrame = CGRectMake(0, 0, windowBounds.size.width, 60);
            width = 270;
            height = 45;
        } else {
            viewFrame = CGRectMake(0, 0, windowBounds.size.width, 40);
            width = 180;
            height = 30;
        }
        UIView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:viewFrame];
        
        if (self.segmentedControl == nil) {
            self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Updates", @"Info", nil]];
            self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
            self.segmentedControl.tintColor = [UIColor grayColor];
            self.segmentedControl.selectedSegmentIndex = 1;
            [self.segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
            self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [view addSubview:self.segmentedControl];
        
        // Handle layouts
        NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:view
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1
                                                                        constant:0];
        NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:view
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0];
        NSLayoutConstraint *constraintSegmentedWidth = [NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:width];
        NSLayoutConstraint *constraintSegmentedHeight = [NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:height];
        [view addConstraints:[NSArray arrayWithObjects:
                              constraintX,
                              constraintY,
                              constraintSegmentedWidth,
                              constraintSegmentedHeight,
                              nil]];
        
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
        return view;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    return view;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            return 60;
        else
            return 43;
    }
    else
        return 10;
}

- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section
{
    if (section == 0)
        return 10;
    return 0.0001;
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
        
        if (self.community != nil) {
            UIImageView *imageView = (UIImageView *) [cell.contentView viewWithTag:1];
            UILabel *titleLabel = (UILabel *) [cell.contentView viewWithTag:2];
            UIButton *joinLeaveButton = (UIButton *) [cell.contentView viewWithTag:3];
            
            if (self.community.logoUrl != nil) {
                [SBTAcmeUtils downloadAndSetImage:imageView url:self.community.logoUrl];
            }
            
            if (self.community.title != nil) {
                titleLabel.text = self.community.title;
            }
            
            if (self.listOfMembers != nil) {
                if ([self isMember]) {
                    [joinLeaveButton setTitle:@"Leave Community" forState:UIControlStateNormal];
                } else {
                    [joinLeaveButton setTitle:@"Join Community" forState:UIControlStateNormal];
                }
            }
        }
        
        return cell;
        
    } else {
        if ([self.state isEqualToString:@"info"]) {
            static NSString *CellIdentifier = @"Cell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                CGRect titleFrame;
                float textSize;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    textSize = TEXT_SIZE_IPAD_SMALL;
                    titleFrame = CGRectMake(10, 5, 500, 45);
                } else {
                    textSize = TEXT_SIZE_SMALL;
                    titleFrame = CGRectMake(10, 5, 240, 30);
                }
                
                UILabel *rowLabel = [[UILabel alloc] initWithFrame:titleFrame];
                rowLabel.backgroundColor = [UIColor clearColor];
                rowLabel.font = [UIFont boldSystemFontOfSize:textSize];
                rowLabel.tag = 1;
                
                [cell.contentView addSubview:rowLabel];
            }
            
            UILabel *rowLabel = (UILabel *) [cell.contentView viewWithTag:1];
            if (indexPath.row == 0)
                rowLabel.text = @"Description";
            else if (indexPath.row == 1) {
                if ([self.listOfMembers count] > 0)
                    rowLabel.text = [NSString stringWithFormat:@"Members (%d)", [self.listOfMembers count]];
                else
                    rowLabel.text = @"Members";
            } else if (indexPath.row == 2)
                rowLabel.text = @"Bookmarks";
            else if (indexPath.row == 3)
                rowLabel.text = @"Files";
            else if (indexPath.row == 4)
                rowLabel.text = @"Forums";
            
            return cell;
        } else {
            IBMActivityStreamEntry *entry = [self.listOfUpdates objectAtIndex:(indexPath.section - 1)];
            if (indexPath.row > 0) {
                entry = [entry.replies objectAtIndex:(indexPath.row-1)];
            }
            
            if ([entry.objectType isEqualToString:@"comment"])
                return [SBTAcmeUtils getCommentCellForEntry:entry tableView:tableView atIndexPath:indexPath viewController:self];
            else
                return [SBTAcmeUtils getStatusUpdateCellForEntry:entry tableView:tableView atIndexPath:indexPath viewController:self];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            return 120;
        else
            return 80;
    }
    else {
        if ([self.state isEqualToString:@"info"]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                return 55;
            else
                return 40;
        }
        else {
            IBMActivityStreamEntry *entry = [self.listOfUpdates objectAtIndex:(indexPath.section - 1)];
            if (indexPath.row > 0) {
                entry = [entry.replies objectAtIndex:(indexPath.row - 1)];
            }
            
            if ([entry.objectType isEqualToString:@"comment"]) {
                return [SBTAcmeUtils getHeightForCommentCell:entry];
            } else {
                return [SBTAcmeUtils getHeightForStatusUpdateCell:entry];
            }
        }
    }
    
    return 40;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
    } else {
        if ([self.state isEqualToString:@"info"]) {
            if (indexPath.row == 0) {
                // Description
                if (self.community.summary != nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Description" message:self.community.summary delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                }
            } else if (indexPath.row == 1) {
                // Members
                // Lets convert IBMCommunityMember to IBMConnectionsProfile to show it in the IBMProfileListView
                NSMutableArray *profiles = [[NSMutableArray alloc] init];
                for (IBMCommunityMember *member in self.listOfMembers) {
                    IBMConnectionsProfile *profile = [[IBMConnectionsProfile alloc] init];
                    profile.userId = member.userId;
                    profile.displayName = member.name;
                    profile.title = member.role;
                    [profiles addObject:profile];
                }
                
                SBTProfileListView *listView = [[SBTProfileListView alloc] init];
                listView.listOfProfiles = profiles;
                listView.title = @"Members";
                [self.navigationController pushViewController:listView animated:YES];
            } else if (indexPath.row == 2) {
                // Bookmarks
                UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
                SBTAcmeBookmarksView *bookmarksView = [[SBTAcmeBookmarksView alloc] init];
                bookmarksView.community = self.community;
                [bookmarksView getBookmarksWithCompletionHandler:^(BOOL success) {
                    [progressView dismissWithClickedButtonIndex:100 animated:YES];
                    if (success) {
                        [self.navigationController pushViewController:bookmarksView animated:YES];
                    }
                }];
            }
        } else {
            // Details of an entry
            UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
            IBMActivityStreamEntry *entry = [self.listOfUpdates objectAtIndex:(indexPath.section - 1)];
            SBTAcmeStatusUpdateView *statusUpdateView = [[SBTAcmeStatusUpdateView alloc] init];
            statusUpdateView.entry = entry;
            statusUpdateView.myProfile = self.myProfile;
            statusUpdateView.community = self.community;
            statusUpdateView.delegateViewController = self;
            [statusUpdateView getEntryWithCompletionHandler:^(BOOL success) {
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                if (success) {
                    [self.navigationController pushViewController:statusUpdateView animated:YES];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
                }
                else
                    [self showAlertViewWithTitle:@"Error" message:@"Error while retriving the details of the update"];
            }];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helper methods

/**
 Add new status update
 */
- (void) addNewPost {
    ComposeUpdate *compose = [[ComposeUpdate alloc] init];
    compose.community = self.community;
    compose.delegateViewController = self;
    [self presentViewController:compose animated:YES completion:^(void) {
        
    }];
}

/**
 Get and see who liked a status update
 */
- (void) whoLikeButtonIsTapped:(LikeButton *) button {
    IBMActivityStreamEntry *entry = button.entry;
    
    if ([entry.numLikes intValue] == 0) {
        return;
    }
    
    UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
    
    IBMConnectionsActivityStreamService *actStrService = [[IBMConnectionsActivityStreamService alloc] init];
    NSString *path = entry.likesUrl;
    path = [path stringByAppendingFormat:@""];
    [[actStrService getClientService] initGetRequestWithPath:path parameters:nil format:RESPONSE_JSON success:^(id response, NSDictionary *resultDict) {
        
        NSMutableArray *peopleLiked = [[NSMutableArray alloc] init];
        NSMutableArray *list = [resultDict objectForKey:@"list"];
        for (NSDictionary *item in list) {
            NSDictionary *author = [item objectForKey:@"author"];
            IBMConnectionsProfile *profile = [[IBMConnectionsProfile alloc] init];
            NSString *actorIdPattern = @"urn:lsid:lconn.ibm.com:profiles.person:";
            if ([[author valueForKey:@"id"] hasPrefix:actorIdPattern]) {
                profile.userId = [[author valueForKey:@"id"] substringFromIndex:[actorIdPattern length]];
            } else {
                profile.userId = [author valueForKey:@"id"];
            }
            profile.displayName = [author valueForKey:@"displayName"];
            [peopleLiked addObject:profile];
        }
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
        SBTProfileListView *listView = [[SBTProfileListView alloc] init];
        listView.listOfProfiles = peopleLiked;
        listView.title = @"Likes";
        [self.navigationController pushViewController:listView animated:YES];
    } failure:^(id response, NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
    }];
}

/**
 This method is executed when a segmented control is selected
 */
- (void) segmentedControlSelected:(UISegmentedControl *) segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0)
        [self showUpdatesWithAlertMessage:nil];
    else
        [self showInfo];
}

/**
 This methods retrieves and show the status updates with an optional message parameter
 @param: message: Message to be displayed in an alert view
 */
- (void) showUpdatesWithAlertMessage:(NSString *) message {
    self.state = @"updates";
    self.navigationItem.rightBarButtonItem = self.addPostItem;
    
    UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
    IBMConnectionsActivityStreamService *actStrSrvc = [[IBMConnectionsActivityStreamService alloc] init];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"true", @"rollup",
                                       @"20", @"count",
                                       nil];
    NSString *communityUuidFull = [NSString stringWithFormat:@"urn:lsid:lconn.ibm.com:communities.community:%@", self.communityUuid];
    [actStrSrvc getActivityStreamsWithParameters:parameters fromUserType:communityUuidFull groupType:@"@all" appType:@"@status" success:^(NSMutableArray *list) {
        [self.listOfUpdates removeAllObjects];
        self.listOfUpdates = list;
        [self.tableView reloadData];
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
        
        if (message != nil) {
            [self showAlertViewWithTitle:@"" message:message];
        } else if ([self.listOfUpdates count] == 0) {
            [self showAlertViewWithTitle:@"" message:@"No update yet! Start sharing by tapping + button"];
        }
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
    }];
}

/**
 Show info about the commmunity
 */
- (void) showInfo {
    self.state = @"info";
    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView reloadData];
}

/**
 Get the community information
 */
- (void) getCommunityWithCompletionHandler:(void (^)(BOOL)) completionHandler {
    IBMConnectionsCommunityService *cs = [[IBMConnectionsCommunityService alloc] init];
    [cs getCommunityWithUuid:self.communityUuid success:^(IBMConnectionsCommunity *community) {
        self.title = community.title;
        self.community = community;
        [self getMembersWithCompletionHandler:completionHandler];
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
        
        completionHandler(NO);
    }];
}

/**
 Get the members of the community
 */
- (void) getMembersWithCompletionHandler:(void (^)(BOOL)) completionHandler {
    IBMConnectionsCommunityService *cs = [[IBMConnectionsCommunityService alloc] init];
    [cs getMembersForCommunity:self.community success:^(NSMutableArray *list) {
        self.listOfMembers = list;
        completionHandler(YES);
    } failure:^(NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
    }];
}

/**
 Check if the currently logged in user is a member of the community
 */
- (BOOL) isMember {
    for (IBMCommunityMember *member in self.listOfMembers) {
        if ([member.userId isEqualToString:self.myProfile.userId]) {
            return YES;
        }
    }
    
    return NO;
}

/**
 This method is executed when user tapped the join/leave button.
 */
- (void) joinOrLeaveCommunity {
    
    self.joinLeaveInProgress = [NSNumber numberWithBool:YES];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    IBMCommunityMember *member = [[IBMCommunityMember alloc] init];
    member.userId = self.myProfile.userId;
    member.email = self.myProfile.email;
    
    UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
    IBMConnectionsCommunityService *communityService = [[IBMConnectionsCommunityService alloc] init];
    if ([self isMember]) {
        [communityService deleteMember:member fromCommunity:self.community success:^(BOOL success) {
            [self getCommunityWithCompletionHandler:^(BOOL success) {
                if (success) {
                    if ([self.state isEqualToString:@"info"])
                        [self.tableView reloadData];
                    else
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];
            [progressView dismissWithClickedButtonIndex:100 animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You successfully left the community!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            self.joinLeaveInProgress = [NSNumber numberWithBool:NO];
        } failure:^(NSError *error) {
            if (IS_DEBUGGING)
                [FBLog log:[error description] from:self];
            
            self.joinLeaveInProgress = [NSNumber numberWithBool:NO];
            [self.tableView reloadData];
            [progressView dismissWithClickedButtonIndex:100 animated:YES];
        }];
    } else {
        [communityService addMember:member fromCommunity:self.community success:^(BOOL success) {
            [self getCommunityWithCompletionHandler:^(BOOL success) {
                if (success) {
                    if ([self.state isEqualToString:@"info"])
                        [self.tableView reloadData];
                    else
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];
            [progressView dismissWithClickedButtonIndex:100 animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You successfully joined to the community!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            self.joinLeaveInProgress = [NSNumber numberWithBool:NO];
        } failure:^(NSError *error) {
            if (IS_DEBUGGING)
                [FBLog log:[error description] from:self];
            
            self.joinLeaveInProgress = [NSNumber numberWithBool:NO];
            [self.tableView reloadData];
            [progressView dismissWithClickedButtonIndex:100 animated:YES];
        }];
    }
}

/**
 This method is called by ComposeUpdate when a status update is successful
 */
- (void) postStatus:(NSDictionary *) userDict {
    if (userDict == nil) {
        [self showUpdatesWithAlertMessage:@"Message is posted successfully!"];
        
    } else {
        NSError *error = [userDict objectForKey:@"error"];
        if (error == nil) {
            [self showUpdatesWithAlertMessage:@"Message is posted successfully!"];
        } else {
            [self showAlertViewWithTitle:@"" message:@"Oops there was a problem while uploading!"];
            if (IS_DEBUGGING)
                [FBLog log:[error description] from:self];
        }
    }
}

/**
 This method is called to pop status update view from stack.
 Usually this happens when a user is in status update view and post a new update
 */
- (void) popStatusUpdateView {
    self.isStatusChanged = nil;
    [self.navigationController popViewControllerAnimated:YES];
    [self showUpdatesWithAlertMessage:@"Message is posted successfully!"];
}

- (void) showAlertViewWithTitle:(NSString *) title message:(NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

/**
 This methods adds all subviews of the info section (section 0)
 */
- (void) addSubViewsToInfoCell:(UITableViewCell *) cell {
    // Logo
    float imageSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        imageSize = 100;
    } else {
        imageSize = 50;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, imageSize, imageSize)];
    imageView.tag = 1;
    
    // Title
    CGRect titleFrame;
    float textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textSize = TEXT_SIZE_IPAD_SMALL;
        titleFrame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5, imageView.frame.origin.y, 400, 45);
    } else {
        textSize = TEXT_SIZE_SMALL;
        titleFrame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5, imageView.frame.origin.y, 220, 30);
    }
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.tag = 2;
    titleLabel.numberOfLines = 2;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    titleLabel.minimumScaleFactor = 0.7;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    
    // Join/Leave button
    CGRect buttonFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        buttonFrame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 4, 180, 45);
    } else {
        buttonFrame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 4, 150, 30);
    }
    UIButton *joinLeaveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    joinLeaveButton.frame = buttonFrame;
    [joinLeaveButton addTarget:self action:@selector(joinOrLeaveCommunity) forControlEvents:UIControlEventTouchUpInside];
    joinLeaveButton.tag = 3;
    joinLeaveButton.titleLabel.font = [UIFont fontWithName:TEXT_FONT size:TEXT_SIZE_SMALL];
    joinLeaveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    joinLeaveButton.titleLabel.minimumScaleFactor = 0.7;
    
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:titleLabel];
    [cell.contentView addSubview:joinLeaveButton];
}

@end
