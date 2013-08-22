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

//  Utils class for various operations

#import "IBMAcmeUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "LikeButton.h"
#import "IBMAcmeStatusUpdateView.h"
#import "IBMCredentialStore.h"
#import "IBMAcmeCommunityView.h"
#import "UIImageView+AFNetworking.h"
#import "IBMConstants.h"
#import "FBLog.h"

@implementation IBMAcmeUtils

+ (NSString *) getAcmeUrl {
    return [IBMCredentialStore loadWithKey:IBM_CREDENTIAL_ACME_URL];
}

+ (void) executeAsyncBlock:(void (^)(void (^completionBlock)(void))) testBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void (^completionBlock)(void) = ^ {
        dispatch_semaphore_signal(semaphore);
    };
    testBlock(completionBlock);
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    }
}

+ (NSString *) getTestCommunityUUidForFlightId:(NSString *) flightId {
    return [IBMCredentialStore loadWithKey:flightId];
}

+ (IBMConnectionsProfile *) getMyProfileForce:(BOOL) force {
    static IBMConnectionsProfile *myProfile = nil;
    if (myProfile == nil || force) {
        void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
            NSString *username = [IBMCredentialStore loadWithKey:IBM_CREDENTIAL_USERNAME];
            IBMConnectionsProfileService *profileService = [[IBMConnectionsProfileService alloc] init];
            [profileService getProfile:username success:^(IBMConnectionsProfile *profile) {
                myProfile = profile;
                completionBlock();
            } failure:^(NSError *error) {
                if (IS_DEBUGGING)
                    [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                
                completionBlock();
            }];
        };
        
        [IBMAcmeUtils executeAsyncBlock:testBlock];
    }
    
    return myProfile;
}

+ (NSString *) timeLabelStrFromdateStr:(NSString *) dateStr {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    NSDate *date = [df dateFromString:dateStr];
    date = [date dateByAddingTimeInterval:-(4*60*60)];
    NSTimeInterval interval = ([[NSDate date] timeIntervalSinceDate:date]);
    NSString *result = @"";
    if (interval < 60) {
        result = @"now";
    } else if (interval/60 < 60) {
        result = [NSString stringWithFormat:@"%dm", ((int)interval/60)];
    } else if (interval/(60*60) < 24) {
        result = [NSString stringWithFormat:@"%dh", ((int)interval/(60*60))];
    } else if (interval/(60*60*24) < 100) {
        result = [NSString stringWithFormat:@"%dd", ((int)interval/(60*60*24))];
    } else {
        result = @"...";
    }
    
    return result;
}

+ (UITableViewCell *) getStatusUpdateCellForEntry:(IBMActivityStreamEntry *) entry tableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath viewController:(UIViewController *) viewController  {
    
    if ([IBMAcmeUtils hasImage:entry] == YES) {
        return [IBMAcmeUtils getStatusUpdateWithImageCellForEntry:entry tableView:tableView atIndexPath:indexPath viewController:viewController];
    }
    
    static NSString *CellIdentifier = @"StatusUpdateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        [IBMAcmeUtils addUpdateViewToCell:cell entry:entry viewController:viewController atIndexPath:indexPath];
    }
    
    UIImageView *imageView = (UIImageView *) [cell.contentView viewWithTag:1];
    UILabel *nameLabel = (UILabel *)  [cell.contentView viewWithTag:2];
    UILabel *updateLabel = (UILabel *) [cell.contentView viewWithTag:3];
    UILabel *timeLabel = (UILabel *) [cell.contentView viewWithTag:5];
    UIView *statsView = (UIView *) [cell.contentView viewWithTag:6];
    UILabel *commentNumberLabel = (UILabel *) [statsView viewWithTag:2];
    UILabel *likeNumberLabel = (UILabel *) [statsView viewWithTag:4];
    LikeButton *likeImageView = (LikeButton *) [statsView viewWithTag:3];
    LikeButton *likeButton = (LikeButton *) [statsView viewWithTag:7];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/profiles/photo.do?userid=%@", [IBMUtils getUrlForEndPoint:@"connections"], entry.actor.aId];
    [IBMAcmeUtils downloadAndSetImage:imageView url:urlStr];
    nameLabel.text = entry.plainTitle;
    
    
    // Remove old constraints
    for (NSLayoutConstraint *co in [cell.contentView constraints]) {
        if ([co.firstItem isEqual:updateLabel]) {
            [cell.contentView removeConstraint:co];
        }
    }
    
    
    CGSize requiredSize = [IBMAcmeUtils getRequiredSizeForText:entry.summary type:@"update"];
    NSLayoutConstraint *constraintHeight;
    constraintHeight = [NSLayoutConstraint constraintWithItem:updateLabel
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:requiredSize.height];
    NSLayoutConstraint *constraintTop;
    constraintTop = [NSLayoutConstraint constraintWithItem:updateLabel
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nameLabel
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *constraintLeft;
    constraintLeft = [NSLayoutConstraint constraintWithItem:updateLabel
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:imageView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:5];
    NSLayoutConstraint *constraintRight;
    constraintRight = [NSLayoutConstraint constraintWithItem:updateLabel
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:cell.contentView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:-10];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintHeight, constraintTop, constraintLeft, constraintRight, nil]];
    
    updateLabel.numberOfLines = requiredSize.height / [IBMAcmeUtils heighForOneLine];
    updateLabel.text = entry.summary;
    timeLabel.text = [IBMAcmeUtils timeLabelStrFromdateStr:entry.updated];
    commentNumberLabel.text = [NSString stringWithFormat:@"%d", [entry.numComments intValue]];
    likeNumberLabel.text = [NSString stringWithFormat:@"%d", [entry.numLikes intValue]];
    
    likeImageView.entry = entry;
    likeImageView.indexPath = indexPath;
    likeButton.entry = entry;
    likeButton.indexPath = indexPath;
    if ([IBMAcmeUtils didILikeThisEntry:entry])
        [likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    else
        [likeButton setTitle:@"Like" forState:UIControlStateNormal];
    
    return cell;
}

+ (UITableViewCell *) getCommentCellForEntry:(IBMActivityStreamEntry *) entry tableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath viewController:(UIViewController *) viewController  {
    static NSString *CellIdentifier = @"CommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        [IBMAcmeUtils addCommentViewToCell:cell entry:entry viewController:viewController atIndexPath:indexPath];
    }
    
    UIImageView *imageView = (UIImageView *) [cell.contentView viewWithTag:1];
    UILabel *nameLabel = (UILabel *)  [cell.contentView viewWithTag:2];
    UILabel *updateLabel = (UILabel *) [cell.contentView viewWithTag:3];
    UILabel *timeLabel = (UILabel *) [cell.contentView viewWithTag:5];
    UIView *statsView = (UIView *) [cell.contentView viewWithTag:6];
    UILabel *likeNumberLabel = (UILabel *) [statsView viewWithTag:4];
    LikeButton *likeImageView = (LikeButton *) [statsView viewWithTag:3];
    LikeButton *likeButton = (LikeButton *) [statsView viewWithTag:7];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/profiles/photo.do?userid=%@", [IBMUtils getUrlForEndPoint:@"connections"], entry.actor.aId];
    [IBMAcmeUtils downloadAndSetImage:imageView url:urlStr];
    nameLabel.text = entry.actor.name;
    
    // Remove old constraints
    for (NSLayoutConstraint *co in [cell.contentView constraints]) {
        if ([co.firstItem isEqual:updateLabel]) {
            [cell.contentView removeConstraint:co];
        }
    }
    
    CGSize requiredSize = [IBMAcmeUtils getRequiredSizeForText:entry.summary type:@"comment"];
    NSLayoutConstraint *constraintHeight;
    constraintHeight = [NSLayoutConstraint constraintWithItem:updateLabel
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:1
                                                     constant:requiredSize.height];
    NSLayoutConstraint *constraintTop;
    constraintTop = [NSLayoutConstraint constraintWithItem:updateLabel
                                                 attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nameLabel
                                                 attribute:NSLayoutAttributeBottom
                                                multiplier:1
                                                  constant:0];
    NSLayoutConstraint *constraintLeft;
    constraintLeft = [NSLayoutConstraint constraintWithItem:updateLabel
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:imageView
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1
                                                   constant:5];
    NSLayoutConstraint *constraintRight;
    constraintRight = [NSLayoutConstraint constraintWithItem:updateLabel
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:cell.contentView
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1
                                                    constant:-10];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintHeight, constraintTop, constraintLeft, constraintRight, nil]];
    
    updateLabel.numberOfLines = requiredSize.height / [IBMAcmeUtils heighForOneLine];
    updateLabel.text = entry.summary;
    
    timeLabel.text = [IBMAcmeUtils timeLabelStrFromdateStr:entry.updated];
    likeNumberLabel.text = [NSString stringWithFormat:@"%d", [entry.numLikes intValue]];
    
    likeImageView.entry = entry;
    likeImageView.indexPath = indexPath;
    likeButton.entry = entry;
    likeButton.indexPath = indexPath;
    if ([IBMAcmeUtils didILikeThisEntry:entry])
        [likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    else
        [likeButton setTitle:@"Like" forState:UIControlStateNormal];
    
    return cell;
}

+ (UITableViewCell *) getStatusUpdateWithImageCellForEntry:(IBMActivityStreamEntry *) entry tableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath viewController:(UIViewController *) viewController  {
    static NSString *CellIdentifier = @"StatusUpdateWithImageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        [IBMAcmeUtils addUpdateImageViewToCell:cell entry:entry viewController:viewController atIndexPath:indexPath];
    }
    
    UIImageView *profilePhotoView = (UIImageView *) [cell.contentView viewWithTag:1];
    UILabel *nameLabel = (UILabel *)  [cell.contentView viewWithTag:2];
    UILabel *updateLabel = (UILabel *) [cell.contentView viewWithTag:3];
    UIImageView *imageView = (UIImageView *) [cell.contentView viewWithTag:4];
    UILabel *timeLabel = (UILabel *) [cell.contentView viewWithTag:5];
    UIView *statsView = (UIView *) [cell.contentView viewWithTag:6];
    UILabel *commentNumberLabel = (UILabel *) [statsView viewWithTag:2];
    UILabel *likeNumberLabel = (UILabel *) [statsView viewWithTag:4];
    LikeButton *likeImageView = (LikeButton *) [statsView viewWithTag:3];
    LikeButton *likeButton = (LikeButton *) [statsView viewWithTag:7];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/profiles/photo.do?userid=%@", [IBMUtils getUrlForEndPoint:@"connections"], entry.actor.aId];
    [IBMAcmeUtils downloadAndSetImage:profilePhotoView url:urlStr];
    nameLabel.text = entry.plainTitle;
    
    // Remove old constraints
    for (NSLayoutConstraint *co in [cell.contentView constraints]) {
        if ([co.firstItem isEqual:updateLabel]) {
            [cell.contentView removeConstraint:co];
        }
    }
    
    CGSize requiredSize = [IBMAcmeUtils getRequiredSizeForText:entry.summary type:@"update"];
    NSLayoutConstraint *constraintHeight;
    constraintHeight = [NSLayoutConstraint constraintWithItem:updateLabel
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:1
                                                     constant:requiredSize.height];
    NSLayoutConstraint *constraintTop;
    constraintTop = [NSLayoutConstraint constraintWithItem:updateLabel
                                                 attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:imageView
                                                 attribute:NSLayoutAttributeBottom
                                                multiplier:1
                                                  constant:0];
    NSLayoutConstraint *constraintLeft;
    constraintLeft = [NSLayoutConstraint constraintWithItem:updateLabel
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:profilePhotoView
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1
                                                   constant:5];
    NSLayoutConstraint *constraintRight;
    constraintRight = [NSLayoutConstraint constraintWithItem:updateLabel
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:cell.contentView
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1
                                                    constant:-10];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintHeight, constraintTop, constraintLeft, constraintRight, nil]];
    
    updateLabel.numberOfLines = requiredSize.height / [IBMAcmeUtils heighForOneLine];
    updateLabel.text = entry.summary;
    
    timeLabel.text = [IBMAcmeUtils timeLabelStrFromdateStr:entry.updated];
    
    commentNumberLabel.text = [NSString stringWithFormat:@"%d", [entry.numComments intValue]];
    likeNumberLabel.text = [NSString stringWithFormat:@"%d", [entry.numLikes intValue]];
    
    likeImageView.entry = entry;
    likeImageView.indexPath = indexPath;
    likeButton.entry = entry;
    likeButton.indexPath = indexPath;
    if ([IBMAcmeUtils didILikeThisEntry:entry])
        [likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    else
        [likeButton setTitle:@"Like" forState:UIControlStateNormal];
    
    // Set image here, use only the first one
    IBMActivityStreamAttachment *attachment = [entry.attachments objectAtIndex:0];
    imageView.image = nil;
    [IBMAcmeUtils downloadAndSetImage:imageView url:attachment.imageUrl];
    
    return cell;
}

+ (CGFloat) getHeightForStatusUpdateCell:(IBMActivityStreamEntry *) entry {
    CGSize requiredSize = [self getRequiredSizeForText:entry.summary type:@"update"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([IBMAcmeUtils hasImage:entry] == YES) {
            return 5 + 45 + 300 + requiredSize.height + 5 + 30 + 5 + 2 + 3 + 3;
        } else {
            return 5 + 45 + requiredSize.height + 5 + 30 + 5 + 3;
        }
    } else {
        if ([IBMAcmeUtils hasImage:entry] == YES) {
            return 5 + 30 + 150 + requiredSize.height + 5 + 15 + 5 + 2 + 3;
        } else {
            return 5 + 30 + requiredSize.height + 5 + 15 + 5;
        }
    }
}

+ (CGFloat) getHeightForCommentCell:(IBMActivityStreamEntry *) entry {
    CGSize requiredSize = [IBMAcmeUtils getRequiredSizeForText:entry.summary type:@"comment"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 5 + 45 + requiredSize.height + 5 + 30 + 5;
    } else {
        return 5 + 30 + requiredSize.height + 5 + 15 + 5;
    }
}

+ (BOOL) hasImage:(IBMActivityStreamEntry *) entry {
    return (entry.attachments != nil &&
            [entry.attachments count] > 0 &&
            [((IBMActivityStreamAttachment *)[entry.attachments objectAtIndex:0]).isImage boolValue] == YES);
}

+ (void) addUpdateViewToCell:(UITableViewCell *) cell entry:(IBMActivityStreamEntry *) entry viewController:(UIViewController *) viewController atIndexPath:(NSIndexPath *) indexPath {
    UIImageView *profilePhotoView = [self addProfilePhotoToCell:cell type:@"update"];
    //UILabel *nameLabel = [self addNameLabelNextToFrame:profilePhotoView.frame forCell:cell type:@"status"];
    UILabel *updateLabel = [self addTextLabelToCell:cell];
    UILabel *timeLabel = [self addTimeLabelNextToFrame:CGRectZero forCell:cell];
    UILabel *nameLabel = [self addNameLabelNextTo:profilePhotoView until:timeLabel forCell:cell type:@"status"];
    UIView *statsView = [self addStatsViewForCell:cell after:updateLabel entry:entry viewController:viewController type:@"status" atIndexPath:indexPath];
    
    [cell.contentView addSubview:profilePhotoView];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:updateLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:statsView];
}

+ (void) addCommentViewToCell:(UITableViewCell *) cell entry:(IBMActivityStreamEntry *) entry viewController:(UIViewController *) viewController atIndexPath:(NSIndexPath *) indexPath {
    // Profile photo
    cell.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    
    UIImageView *profilePhotoView = [self addProfilePhotoToCell:cell type:@"comment"];
    //UILabel *nameLabel = [self addNameLabelNextToFrame:profilePhotoView.frame forCell:cell type:@"comment"];
    UILabel *updateLabel = [self addTextLabelToCell:cell];
    UILabel *timeLabel = [self addTimeLabelNextToFrame:CGRectZero forCell:cell];
    UILabel *nameLabel = [self addNameLabelNextTo:profilePhotoView until:timeLabel forCell:cell type:@"comment"];
    UIView *statsView = [self addStatsViewForCell:cell after:updateLabel entry:entry viewController:viewController type:@"comment" atIndexPath:indexPath];
    
    [cell.contentView addSubview:profilePhotoView];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:updateLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:statsView];
}

+ (void) addUpdateImageViewToCell:(UITableViewCell *) cell entry:(IBMActivityStreamEntry *) entry viewController:(UIViewController *) viewController atIndexPath:(NSIndexPath *) indexPath {
    UIImageView *profilePhotoView = [self addProfilePhotoToCell:cell type:@"update"];
    //UILabel *nameLabel = [self addNameLabelNextToFrame:profilePhotoView.frame forCell:cell type:@"update"];
    UILabel *updateLabel = [self addTextLabelToCell:cell];
    UILabel *timeLabel = [self addTimeLabelNextToFrame:CGRectZero forCell:cell];
    UILabel *nameLabel = [self addNameLabelNextTo:profilePhotoView until:timeLabel forCell:cell type:@"status"];
    UIImageView *imageView = [self addImageViewToCell:cell afterView:nameLabel];
    UIView *statsView = [self addStatsViewForCell:cell after:updateLabel entry:entry viewController:viewController type:@"status" atIndexPath:indexPath];
    
    [cell.contentView addSubview:profilePhotoView];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:updateLabel];
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:statsView];
}

+ (UIImageView *) addProfilePhotoToCell:(UITableViewCell *) cell type:(NSString *) type {
    NSInteger size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([type isEqualToString:@"update"])
            size = 80;
        else
            size = 60;
    } else {
        if ([type isEqualToString:@"update"])
            size = 40;
        else
            size = 30;
    }
    
    UIImageView *profilePhotoView = [[UIImageView alloc] init];
    profilePhotoView.tag = 1;
    profilePhotoView.layer.masksToBounds = YES;
    profilePhotoView.layer.cornerRadius = 5;
    profilePhotoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:profilePhotoView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:size];
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:profilePhotoView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:size];
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:profilePhotoView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:5];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:profilePhotoView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:cell.contentView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:5];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintWidth, constraintHeight, constraintTop, constraintLeft, nil]];

    return profilePhotoView;
}

+ (UILabel *) addNameLabelNextTo:(id) nextTo until:(id) until forCell:(UITableViewCell *) cell type:(NSString *) type {
    NSInteger noOfLines;
    NSInteger width;
    NSInteger height;
    float textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textSize = TEXT_SIZE_IPAD_SMALL;
        if ([type isEqualToString:@"comment"]) {
            noOfLines = 2;
            width = 600;
            height = 45;
        } else {
            noOfLines = 2;
            width = 420;
            height = 45;
        }
    } else {
        textSize = TEXT_SIZE_SMALL-2;
        if ([type isEqualToString:@"comment"]) {
            noOfLines = 2;
            width = 210;
            height = 30;
        } else {
            noOfLines = 2;
            width = 200;
            height = 30;
        }
    }
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.tag = 2;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:textSize];
    //nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.numberOfLines = noOfLines;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:height];
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:cell.contentView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:2];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nextTo
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:5];
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:until
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:0];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintHeight, constraintTop, constraintLeft, constraintRight, nil]];
    
    return nameLabel;
}

+ (UILabel *) addTextLabelToCell:(UITableViewCell *) cell {
    UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    updateLabel.tag = 3;
    updateLabel.backgroundColor = [UIColor clearColor];
    updateLabel.font = [UIFont fontWithName:TEXT_FONT size:[IBMAcmeUtils getUpdateTextSize]];
    //updateLabel.textColor = [UIColor colorWithRed:68.0/255 green:68.0/255 blue:68.0/255 alpha:1];
    updateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    return updateLabel;
}

+ (UIImageView *) addImageViewToCell:(UITableViewCell *) cell afterView:(id) view {
    
    float size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        size = 300;
    } else {
        size = 150;
    }
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.tag = 4;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 5;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:imageView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:size];
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:imageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:view
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:imageView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:0];
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:imageView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:view
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1
                                                                       constant:0];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintHeight, constraintTop, constraintLeft, constraintRight, nil]];
    
    return imageView;
}

+ (UILabel *) addTimeLabelNextToFrame:(CGRect) frame forCell:(UITableViewCell *) cell {
    float width;
    float height;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = 40;
        height = 30;
    } else {
        width = 40;
        height = 20;
    }
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.tag = 5;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont fontWithName:TEXT_FONT size:[IBMAcmeUtils getTimeTextSize]];
    timeLabel.textColor = [UIColor colorWithRed:136.0/255 green:136.0/255 blue:136.0/255 alpha:1];
    timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:timeLabel
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:width];
    
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:timeLabel
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:height];
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:timeLabel
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:cell.contentView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:5];
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:timeLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:cell.contentView
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:-5];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintWidth, constraintHeight, constraintTop, constraintRight, nil]];
    
    return timeLabel;
}

+ (UIView *) addStatsViewForCell:(UITableViewCell *) cell after:(id) afterView entry:(IBMActivityStreamEntry *) entry viewController:(UIViewController *) viewController type:(NSString *) type atIndexPath:(NSIndexPath *) indexPath {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    view.tag = 6;
    
    NSInteger width;
    NSInteger height;
    float textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textSize = TEXT_SIZE_IPAD_SMALL - 2;
        width = 30;
        height = 30;
    } else {
        textSize = TEXT_SIZE_SMALL - 3;
        width = 15;
        height = 15;
    }
    
    UILabel *likeNumberLabel;
    
    if ([type isEqualToString:@"comment"]) {
        LikeButton *likeImageView = [LikeButton buttonWithType:UIButtonTypeCustom];
        likeImageView.entry = entry;
        likeImageView.frame = CGRectMake(0, 0, width, height);
        [likeImageView setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [likeImageView addTarget:viewController action:@selector(whoLikeButtonIsTapped:) forControlEvents:UIControlEventTouchUpInside];
        likeImageView.tag = 3;
        
        likeNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(likeImageView.frame.origin.x + likeImageView.frame.size.width + 2, likeImageView.frame.origin.y, width, height)];
        likeNumberLabel.backgroundColor = [UIColor clearColor];
        likeNumberLabel.tag = 4;
        likeNumberLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
        likeNumberLabel.textColor = [UIColor colorWithRed:136.0/255 green:136.0/255 blue:136.0/255 alpha:1];
        
        [view addSubview:likeImageView];
        [view addSubview:likeNumberLabel];
    } else {
        UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        commentImageView.image = [UIImage imageNamed:@"comment.png"];
        commentImageView.tag = 1;
        
        UILabel *commentNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(commentImageView.frame.origin.x + commentImageView.frame.size.width + 2, commentImageView.frame.origin.y, width, height)];
        commentNumberLabel.backgroundColor = [UIColor clearColor];
        commentNumberLabel.tag = 2;
        commentNumberLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
        commentNumberLabel.textColor = [UIColor colorWithRed:136.0/255 green:136.0/255 blue:136.0/255 alpha:1];
        
        LikeButton *likeImageView = [LikeButton buttonWithType:UIButtonTypeCustom];
        likeImageView.frame = CGRectMake(commentNumberLabel.frame.origin.x + commentNumberLabel.frame.size.width + 2, commentNumberLabel.frame.origin.y, width, height);
        [likeImageView setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [likeImageView addTarget:viewController action:@selector(whoLikeButtonIsTapped:) forControlEvents:UIControlEventTouchUpInside];
        likeImageView.tag = 3;
        
        likeNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(likeImageView.frame.origin.x + likeImageView.frame.size.width + 2, likeImageView.frame.origin.y, width, height)];
        likeNumberLabel.backgroundColor = [UIColor clearColor];
        likeNumberLabel.tag = 4;
        likeNumberLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
        likeNumberLabel.textColor = [UIColor colorWithRed:136.0/255 green:136.0/255 blue:136.0/255 alpha:1];
        
        [view addSubview:commentImageView];
        [view addSubview:commentNumberLabel];
        [view addSubview:likeImageView];
        [view addSubview:likeNumberLabel];
    }
    if ([viewController isKindOfClass:[IBMAcmeCommunityView class]] == NO) {
        LikeButton *likeButton = [LikeButton buttonWithType:UIButtonTypeCustom];
        likeButton.frame = CGRectMake(likeNumberLabel.frame.origin.x + likeNumberLabel.frame.size.width + 3, likeNumberLabel.frame.origin.y, 3 * width, height);
        [likeButton setTitleColor:[UIColor colorWithRed:136.0/255 green:136.0/255 blue:136.0/255 alpha:1] forState:UIControlStateNormal];
        [likeButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [likeButton.titleLabel setFont:[UIFont fontWithName:TEXT_FONT size:textSize + 2]];
        [likeButton addTarget:viewController action:@selector(likeButtonIsTapped:) forControlEvents:UIControlEventTouchUpInside];
        likeButton.tag = 7;
        
        [view addSubview:likeButton];
    }
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:height];
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:afterView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:5];
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:afterView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:afterView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:0];
    [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintHeight, constraintTop, constraintRight, constraintLeft, nil]];
    
    return view;
}

+ (BOOL) didILikeThisEntry:(IBMActivityStreamEntry *) entry {
    IBMConnectionsProfile *myProfile = [IBMAcmeUtils getMyProfileForce:NO];
    NSMutableArray *likes;
    if ([entry.objectObjectType isEqualToString:@"comment"])
        likes = entry.targetLikes;
    else
        likes = entry.objectLikes;
    
    for (IBMActivityStreamActor *actor in likes) {
        if ([actor.aId isEqualToString:myProfile.userId]) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSInteger) getUpdateTextSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return TEXT_SIZE_IPAD;
    else
        return TEXT_SIZE;
}

+ (NSInteger) getCommentTextSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return TEXT_SIZE_IPAD;
    else
        return TEXT_SIZE;
}

+ (NSInteger) getTimeTextSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return TEXT_SIZE_IPAD_SMALL-3;
    else
        return TEXT_SIZE_SMALL-3;
}

+ (CGSize) getRequiredSizeForText:(NSString *) text type:(NSString *) type {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect windowBounds = [[UIScreen mainScreen] bounds];
    float width = windowBounds.size.width;
    
    if(orientation == 0) {
        //Portrait
        width = windowBounds.size.width;
    } else if(orientation == UIInterfaceOrientationPortrait) {
        //Portrait
        width = windowBounds.size.width;
    } else if(orientation == UIInterfaceOrientationLandscapeLeft) {
        // Left landscape
        width = windowBounds.size.height;
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        // Right landscape
        width = windowBounds.size.height;
    }
    
    float marginOfProfilePhotoFromRight = 5;
    float marginFromProfilePhoto = 5;
    float marginFromRight = 10;
    float profilePhotoSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([type isEqualToString:@"update"])
            profilePhotoSize = 80;
        else
            profilePhotoSize = 60;
    } else {
        if ([type isEqualToString:@"update"])
            profilePhotoSize = 40;
        else
            profilePhotoSize = 30;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([type isEqualToString:@"update"]) {
            CGSize constrainedSize = CGSizeMake(width-2*MARGIN_FOR_IPAD_GROUPED_TABLEVIEW-marginOfProfilePhotoFromRight - profilePhotoSize - marginFromProfilePhoto - marginFromRight, 800);
            CGSize requiredSize = [text sizeWithFont:[UIFont fontWithName:TEXT_FONT size:[IBMAcmeUtils getUpdateTextSize]] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
            
            return requiredSize;
        } else {
            // Comment
            CGSize constrainedSize = CGSizeMake(width-2*MARGIN_FOR_IPAD_GROUPED_TABLEVIEW-marginOfProfilePhotoFromRight - profilePhotoSize - marginFromProfilePhoto - marginFromRight, 800);
            CGSize requiredSize = [text sizeWithFont:[UIFont fontWithName:TEXT_FONT size:[IBMAcmeUtils getCommentTextSize]] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
            
            return requiredSize;
        }
    } else {
        if ([type isEqualToString:@"update"]) {
            CGSize constrainedSize = CGSizeMake(width-2*MARGIN_FOR_IPHONE_GROUPED_TABLEVIEW-marginOfProfilePhotoFromRight - profilePhotoSize - marginFromProfilePhoto - marginFromRight, 800);
            CGSize requiredSize = [text sizeWithFont:[UIFont fontWithName:TEXT_FONT size:[IBMAcmeUtils getUpdateTextSize]] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
            
            return requiredSize;
        } else {
            // Comment
            CGSize constrainedSize = CGSizeMake(width-2*MARGIN_FOR_IPHONE_GROUPED_TABLEVIEW -marginOfProfilePhotoFromRight - profilePhotoSize - marginFromProfilePhoto - marginFromRight, 800);
            CGSize requiredSize = [text sizeWithFont:[UIFont fontWithName:TEXT_FONT size:[IBMAcmeUtils getCommentTextSize]] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
            
            return requiredSize;
        }
    }
}

+ (CGFloat) heighForOneLine {
    float textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        textSize = TEXT_SIZE_IPAD;
    else
        textSize = TEXT_SIZE;
    
    CGSize constrainedSize = CGSizeMake(1000, 1000);
    CGSize heightForOneLine = [@" " sizeWithFont:[UIFont fontWithName:TEXT_FONT size:textSize] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
    
    return heightForOneLine.height;
}

+ (void) downloadAndSetImage:(UIImageView *) imageView url:(NSString *) url {
    UIImage *placeHolderImage;
    if ([url rangeOfString:@"profile"].location != NSNotFound) {
        placeHolderImage = [UIImage imageNamed:@"profile_photo_default.png"];
    } else {
        placeHolderImage = [UIImage imageNamed:@"placeholder_image.png"];
    }
    
    [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeHolderImage];
}

+ (UIAlertView *) showProgressBar {
    UIAlertView *progressView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actIndicator.frame = CGRectMake(80, 25, 30, 30);
    [actIndicator startAnimating];
    [progressView addSubview:actIndicator];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(actIndicator.frame.origin.x + actIndicator.frame.size.width + 8, actIndicator.frame.origin.y, 100, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Loading...";
    label.textColor = [UIColor whiteColor];
    [progressView addSubview:label];
    [progressView show];
    
    return progressView;
}

@end
