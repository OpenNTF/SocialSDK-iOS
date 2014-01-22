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
//  This class represent FileEntry object for IBM Connections

#import "SBTXMLDocument.h"
#import "SBTFileCommentEntry.h"
#import "SBTFilePersonEntry.h"

@interface SBTFileEntry : NSObject

@property (strong, nonatomic) SBTXMLDocument *xmlDocument;
@property (strong, nonatomic) NSString *fileId;
@property (strong, nonatomic) NSString *creatorId;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *lock;
@property (strong, nonatomic) NSString *libraryType;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *totalResults;
@property (strong, nonatomic) SBTFileCommentEntry *commentEntry;
@property (strong, nonatomic) SBTFilePersonEntry *personEntry;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSNumber *recommendationsCount;
@property (strong, nonatomic) NSNumber *sharesCount;
@property (strong, nonatomic) NSNumber *foldersCount;
@property (strong, nonatomic) NSNumber *attachmentsCount;
@property (strong, nonatomic) NSNumber *versionsCount;
@property (strong, nonatomic) NSNumber *referencesCount;

#pragma mark - read only properties
@property (strong, readonly) NSString *published;
@property (strong, readonly) NSString *updated;
@property (strong, readonly) NSString *created;
@property (strong, readonly) NSString *modified;
@property (strong, readonly) NSString *lastAccessed;
@property (strong, readonly) SBTFilePersonEntry *modifier;
@property (strong, readonly) NSString *visibility;
@property (strong, readonly) NSString *libraryId;
@property (strong, readonly) NSString *versionLabel;
@property (strong, readonly) NSString *propogation;
@property (strong, readonly) NSString *totalMediaSize;
@property (strong, readonly) NSString *objectTypeId;


/* Fields dictionary for holding changed or created fields */
//@property (strong, nonatomic) NSMutableDictionary *fieldsDict;

#pragma mark - methods

- (id) init;
- (id) initWithXMLDocument:(SBTXMLDocument *) document;
+ (NSDictionary *) namespacesForFileEntry;
- (NSString *) description;


@end
