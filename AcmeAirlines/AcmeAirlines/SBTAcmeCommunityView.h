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

#import <UIKit/UIKit.h>
#import "IBMConnectionsProfile.h"

@interface IBMAcmeCommunityView : UITableViewController

@property (strong, nonatomic) NSString *communityUuid;
@property (strong, nonatomic) IBMConnectionsProfile *myProfile;
@property (strong, nonatomic) NSNumber *isStatusChanged;

/**
 This method is called by ComposeUpdate when a status update is successful
 */
- (void) postStatus:(NSDictionary *) userDict;

/**
 This method is called to pop status update view from stack.
 Usually this happens when a user is in status update view and post a new update
 */
- (void) popStatusUpdateView;

/**
 This method allows parent viewcontroller to be able to request community information before showing the view.
 */
- (void) getCommunityWithCompletionHandler:(void (^)(BOOL)) completionHandler;

@end
