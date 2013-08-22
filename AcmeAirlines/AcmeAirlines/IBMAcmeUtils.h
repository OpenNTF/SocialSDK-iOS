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

#import <Foundation/Foundation.h>
#import "IBMAcmeConstant.h"
#import "IBMActivityStreamEntry.h"
#import "IBMConnectionsProfileService.h"

@interface IBMAcmeUtils : NSObject

/**
 Retrieve the base url for Acme App from Credential Store
 */
+ (NSString *) getAcmeUrl;

/**
 Get currently logged in user's profile
 @param force: if YES, it will retrieve it again. Otherwise static variable will be returned
 */
+ (IBMConnectionsProfile *) getMyProfileForce:(BOOL) force;

/**
 Get the test community uuid from Credential Store
 */
+ (NSString *) getTestCommunityUUidForFlightId:(NSString *) flightId;

/**
 Format the time information as 1h, 1d etc.
 */
+ (NSString *) timeLabelStrFromdateStr:(NSString *) dateStr;

/**
 This method returns a table view cell for status update
 */
+ (UITableViewCell *) getStatusUpdateCellForEntry:(IBMActivityStreamEntry *) entry tableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath viewController:(UIViewController *) viewController;

/**
 This method returns a table view cell for comment entry
 */
+ (UITableViewCell *) getCommentCellForEntry:(IBMActivityStreamEntry *) entry tableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath viewController:(UIViewController *) viewController;

/**
 This method returns a table view cell for status update with an image in it
 */
+ (UITableViewCell *) getStatusUpdateWithImageCellForEntry:(IBMActivityStreamEntry *) entry tableView:(UITableView *) tableView atIndexPath:(NSIndexPath *) indexPath viewController:(UIViewController *) viewController;

/**
 Get the actual height of the given entry for status update
 */
+ (CGFloat) getHeightForStatusUpdateCell:(IBMActivityStreamEntry *) entry;

/**
 Get the actual height of the given entry for comment
 */
+ (CGFloat) getHeightForCommentCell:(IBMActivityStreamEntry *) entry;

/**
 Text Size for the status updaye
 */
+ (NSInteger) getUpdateTextSize;

/**
 Get text size for the comment
 */
+ (NSInteger) getCommentTextSize;

/**
 Get text size for the time label
 */
+ (NSInteger) getTimeTextSize;

/**
 Get required size of a given text entry to dynamically adjust height
 @param text: String text
 @param type: Comment Cell, Status Update Cell etc.
 */
+ (CGSize) getRequiredSizeForText:(NSString *) text type:(NSString *) type;

/**
 Height of a single line
 */
+ (CGFloat) heighForOneLine;

/**
 Download and set the image to the given imageview
 @param imageview: used to show the image
 @param url: url string to download image
 */
+ (void) downloadAndSetImage:(UIImageView *) imageView url:(NSString *) url;

/**
 Convenience method to decide if I liked a given entry
 */
+ (BOOL) didILikeThisEntry:(IBMActivityStreamEntry *) entry;

/**
 Determine if an entry has an image
 */
+ (BOOL) hasImage:(IBMActivityStreamEntry *) entry;

/**
 Show progress bar to indicate some processing is taking place
 */
+ (UIAlertView *) showProgressBar;

/**
 If an asynchronous block needs to be run syncrhonously, used this convenience method.
 */
+ (void) executeAsyncBlock:(void (^)(void (^completionBlock)(void))) testBlock;

@end
