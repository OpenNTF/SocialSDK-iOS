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

#import <Foundation/Foundation.h>
#import "IBMXMLDocument.h"

@interface IBMCommunityBookmark : NSObject

#pragma mark - properties

@property (strong, nonatomic) IBMXMLDocument *xmlDocument;
@property (strong, nonatomic) NSString *bId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *bUrl;

/* Fields dictionary for holding changed or created fields */
@property (strong, nonatomic) NSMutableDictionary *fieldsDict;

#pragma mark - methods

- (id) init;
- (id) initWithXMLDocument:(IBMXMLDocument *) document;
+ (NSDictionary *) namespacesForCommunityBookmark;
- (NSString *) description;

@end
