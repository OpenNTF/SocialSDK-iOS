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

//  LikeButton used in status update and comment cells

#import <UIKit/UIKit.h>
#import <iOSSBTK/SBTActivityStreamEntry.h>

@interface LikeButton : UIButton

// Entry to be liked
@property (strong, nonatomic) SBTActivityStreamEntry *entry;

// Indexpath of the entry
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
