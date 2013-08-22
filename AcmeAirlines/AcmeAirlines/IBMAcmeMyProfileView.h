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

#import <UIKit/UIKit.h>
#import "IBMConnectionsProfile.h"

@interface IBMAcmeMyProfileView : UITableViewController

@property (strong, nonatomic) IBMConnectionsProfile *myProfile;
@property (strong, nonatomic) NSString *comingFrom;

/**
 This method allow parent view controller to retrieve profile before showing the view
 */
- (void) retrieveProfileWithCompletionHandler:(void (^)(BOOL)) completionHandler;

@end
