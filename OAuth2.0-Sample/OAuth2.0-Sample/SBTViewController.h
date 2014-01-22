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

//  This is the controller of the main view. It allows user to authenticate, logout and explore some of the APIs that reuqire authentication

#import <UIKit/UIKit.h>

@interface SBTViewController : UIViewController

- (IBAction)authenticate:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)explore:(id)sender;

@end
