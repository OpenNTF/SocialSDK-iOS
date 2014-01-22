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
#import "SBTXMLDocument.h"

@interface SBTFilePersonEntry : NSObject

typedef enum {
    FP_AUTHOR,
    FP_MODIFIER
} FP_USER_TYPE;

@property (strong, nonatomic) SBTXMLDocument *xmlDocument;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *userState;
@property (strong, nonatomic) NSString *userUuid;


/* Fields dictionary for holding changed or created fields */
//@property (strong, nonatomic) NSMutableDictionary *fieldsDict;

#pragma mark - methods

- (id) init;
- (id) initWithXMLDocument:(SBTXMLDocument *) document userType:(FP_USER_TYPE) type;
+ (NSDictionary *) namespacesForPersonEntry;
- (NSString *) description;

@end
