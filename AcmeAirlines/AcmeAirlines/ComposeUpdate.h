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

#import <UIKit/UIKit.h>
#import <iOSSBTK/SBTConnectionsCommunity.h>
#import <iOSSBTK/SBTActivityStreamEntry.h>
#import <iOSSBTK/SBTConnectionsActivityStreamService.h>

@interface ComposeUpdate : UIViewController

@property (strong, nonatomic) SBTConnectionsCommunity *community;
@property (strong, nonatomic) SBTActivityStreamEntry *entry;
@property (nonatomic, strong) UIViewController *delegateViewController;

- (void) alert:(NSString *) title message:(NSString *) message;
- (void) setTitleOfViewWithString:(NSString *) title;
- (IBAction) addImage:(id)sender;
- (void) hideTakePhotoButton:(BOOL) hide;

@end
