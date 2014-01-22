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

#import "SBTFileEntry.h"
#import "SBTConstants.h"
#import "FBLog.h"

@interface SBTFileEntry ()

@property (strong, nonatomic) NSMutableDictionary *xpathMap;

@end

@implementation SBTFileEntry

@synthesize fileId = _fileId, creatorId = _creatorId, label = _label, lock = _lock, libraryType = _libraryType, category = _category, totalResults = _totalResults, commentEntry = _commentEntry, personEntry = _personEntry, title = _title, summary = _summary, commentsCount = _commentsCount, recommendationsCount = _recommendationsCount, sharesCount = _sharesCount, foldersCount = _foldersCount, attachmentsCount = _attachmentsCount, versionsCount = _versionsCount, referencesCount = _referencesCount, published = _published, updated = _updated, created = _created, modified = _modified, lastAccessed = _lastAccessed, modifier = _modifier, visibility = _visibility, libraryId = _libraryId, versionLabel = _versionLabel, propogation = _propogation, totalMediaSize = _totalMediaSize, objectTypeId = _objectTypeId;

- (id) init {
    if (self = [super init]) {
        [self initEnv];
    }
    
    return self;
}

- (id) initWithXMLDocument:(SBTXMLDocument *)document {
    if (self = [super init]) {
        [self initEnv];
        self.xmlDocument = document;
    }
    
    return self;
}

- (void) initEnv {
    //self.fieldsDict = [[NSMutableDictionary alloc] init];
    self.xpathMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     @"/a:feed/a:author/a:email", @"email",
                     @"/a:entry/a:author/a:email", @"emailFromEntry",
                     @"/a:entry/a:author/snx:userid", @"userUuidFromEntry",
                     @"/a:entry/a:author/a:name", @"nameOfUserFromEntry",
                     @"/a:entry/a:author/snx:userState", @"userStateFromEntry",
                     @"/a:entry/td:modifier/snx:userState", @"userStateModifier",
                     @"/a:entry/td:modifier/a:name", @"nameModifier",
                     @"/a:entry/td:modifier/snx:userid", @"userUuidModifier",
                     @"/a:entry/td:modifier/a:email", @"emailModifier",
                     @"/a:feed/a:entry/a:title", @"fileName",
                     @"/a:feed/a:entry/td:uuid", @"fileUuid",
                     @"/a:entry/a:link[@rel=\"edit-media\"]/@href", @"downLinkFromEntry",
                     @"/a:entry/a:content", @"commentFromEntry",
                     @"/a:feed/a:entry/a:content", @"comment",
                     @"/a:feed/a:entry", @"entry",
                     @"/a:entry/td:uuid", @"uuidFromEntry",
                     @"/a:entry/td:lock/@type", @"lockFromEntry",
                     @"/a:entry/td:label", @"labelFromEntry",
                     @"/a:entry/a:category/@label", @"categoryFromEntry",
                     @"/a:entry/td:modified", @"modifiedFromEntry",
                     @"/a:entry/td:visibility", @"visibilityFromEntry",
                     @"/a:entry/td:libraryType", @"libraryTypeFromEntry",
                     @"/a:entry/td:versionUuid", @"versionUuidFromEntry",
                     @"/a:entry/a:summary", @"summaryFromEntry",
                     @"/a:entry/td:restrictedVisibility", @"restrictedVisibilityFromEntry",
                     @"/a:entry/a:title", @"titleFromEntry",
                     @"/a:feed/opensearch:totalResults", @"totalResults",
                     @"/a:entry/a:published", @"publishedFromEntry",
                     @"/a:entry/a:updated", @"updatedFromEntry",
                     @"/a:entry/td:created", @"createdFromEntry",
                     @"/a:entry/td:modified", @"modifiedFromEntry",
                     @"/a:entry/td:lastAccessed", @"lastAccessedFromEntry",
                     @"/a:entry/td:visibility", @"visibilityFromEntry",
                     @"/a:entry/td:libraryId", @"libraryIdFromEntry",
                     @"/a:entry/td:libraryType", @"libraryTypeFromEntry",
                     @"/a:entry/td:versionLabel", @"versionLabelFromEntry",
                     @"/a:entry/td:propagation", @"propagationFromEntry",
                     @"/a:entry/td:totalMediaSize", @"totalMediaSizeFromEntry",
                     @"/a:entry/td:objectTypeId", @"objectTypeIdFromEntry",
                     @"/a:entry/snx:rank[@scheme='http://www.ibm.com/xmlns/prod/sn/comment']", @"commentsCount",
                     @"/a:entry/snx:rank[@scheme='http://www.ibm.com/xmlns/prod/sn/recommendations']", @"recommendationsCount",
                     @"/a:entry/snx:rank[@scheme='http://www.ibm.com/xmlns/prod/sn/share']", @"sharesCount",
                     @"/a:entry/snx:rank[@scheme='http://www.ibm.com/xmlns/prod/sn/collections']", @"foldersCount",
                     @"/a:entry/snx:rank[@scheme='http://www.ibm.com/xmlns/prod/sn/attachments']", @"attachmentsCount",
                     @"/a:entry/snx:rank[@scheme='http://www.ibm.com/xmlns/prod/sn/versions']", @"versionsCount",
                     @"/a:entry/snx:rank[@scheme='http://www.ibm.com/xmlns/prod/sn/references']", @"referencesCount",
                     nil];
}

- (NSString *)fileId {
    if (_fileId == nil) {
        _fileId = [self getFieldWithXPath:@"uuidFromEntry"];
    }
    
    return _fileId;
}

- (NSString *)label {
    if (_label == nil) {
        _label = [self getFieldWithXPath:@"labelFromEntry"];
    }
    
    return _label;
}

- (NSString *)lock {
    if (_lock == nil) {
        _lock = [self getFieldWithXPath:@"lockFromEntry"];
    }
    
    return _lock;
}

- (NSString *)libraryType {
    if (_libraryType == nil) {
        _libraryType = [self getFieldWithXPath:@"libraryTypeFromEntry"];
    }
    
    return _libraryType;
}

- (NSString *)category {
    if (_category == nil) {
        _category = [self getFieldWithXPath:@"categoryFromEntry"];
    }
    
    return _category;
}

- (NSString *)totalResults {
    if (_totalResults == nil) {
        _totalResults = [self getFieldWithXPath:@"totalResults"];
    }
    
    return _totalResults;
}

- (SBTFileCommentEntry *)commentEntry {
    // There isn't any direct field in the xml to get comments
    return _commentEntry;
}

- (SBTFilePersonEntry *)personEntry {
    if (_personEntry == nil) {
        _personEntry = [[SBTFilePersonEntry alloc] initWithXMLDocument:self.xmlDocument userType:FP_AUTHOR];
    }
    
    return _personEntry;
}

- (NSString *)title {
    if (_title == nil) {
        _title = [self getFieldWithXPath:@"titleFromEntry"];
    }
    
    return _title;
}

- (NSString *)summary {
    if (_summary == nil) {
        _summary = [self getFieldWithXPath:@"summaryFromEntry"];
    }
    
    return _summary;
}

- (NSNumber *)commentsCount {
    if (_commentsCount == nil) {
        _commentsCount = [self getFieldWithXPath:@"commentsCount"];
    }
    
    return _commentsCount;
}

- (NSNumber *)recommendationsCount {
    if (_recommendationsCount == nil) {
        _recommendationsCount = [self getFieldWithXPath:@"recommendationsCount"];
    }
    
    return _recommendationsCount;
}

- (NSNumber *)sharesCount {
    if (_sharesCount == nil) {
        _sharesCount = [self getFieldWithXPath:@"sharesCount"];
    }
    
    return _sharesCount;
}

- (NSNumber *)foldersCount {
    if (_foldersCount == nil) {
        _foldersCount = [self getFieldWithXPath:@"foldersCount"];
    }
    
    return _foldersCount;
}

- (NSNumber *)attachmentsCount {
    if (_attachmentsCount == nil) {
        _attachmentsCount = [self getFieldWithXPath:@"attachmentsCount"];
    }
    
    return _attachmentsCount;
}

- (NSNumber *)versionsCount {
    if (_versionsCount == nil) {
        _versionsCount = [self getFieldWithXPath:@"versionsCount"];
    }
    
    return _versionsCount;
}

- (NSNumber *)referencesCount{
    if (_referencesCount == nil) {
        _referencesCount = [self getFieldWithXPath:@"referencesCount"];
    }
    
    return _referencesCount;
}

- (NSString *)published {
    if (_published == nil) {
        _published = [self getFieldWithXPath:@"publishedFromEntry"];
    }
    
    return _published;
}

- (NSString *)updated {
    if (_updated == nil) {
        _updated = [self getFieldWithXPath:@"updatedFromEntry"];
    }
    
    return _updated;
}

- (NSString *)created {
    if (_created == nil) {
        _created = [self getFieldWithXPath:@"createdFromEntry"];
    }
    
    return _created;
}

- (NSString *)modified {
    if (_modified == nil) {
        _modified = [self getFieldWithXPath:@"modifiedFromEntry"];
    }
    
    return _modified;
}

- (NSString *)lastAccessed {
    if (_lastAccessed == nil) {
        _lastAccessed = [self getFieldWithXPath:@"lastAccessedFromEntry"];
    }
    
    return _lastAccessed;
}

- (SBTFilePersonEntry *)modifier {
    if (_modifier == nil) {
        _modifier = [[SBTFilePersonEntry alloc] initWithXMLDocument:self.xmlDocument userType:FP_MODIFIER];
    }
    
    return _modifier;
}

- (NSString *)visibility {
    if (_visibility == nil) {
        _visibility = [self getFieldWithXPath:@"visibilityFromEntry"];
    }
    
    return _visibility;
}

- (NSString *)libraryId {
    if (_libraryId == nil) {
        _libraryId = [self getFieldWithXPath:@"libraryIdFromEntry"];
    }
    
    return _libraryId;
}

- (NSString *)versionLabel {
    if (_versionLabel == nil) {
        _versionLabel = [self getFieldWithXPath:@"versionLabelFromEntry"];
    }
    
    return _versionLabel;
}

- (NSString *)propogation {
    if (_propogation == nil) {
        _propogation = [self getFieldWithXPath:@"propagationFromEntry"];
    }
    
    return _propogation;
}

- (NSString *)totalMediaSize {
    if (_totalMediaSize == nil) {
        _totalMediaSize = [self getFieldWithXPath:@"totalMediaSizeFromEntry"];
    }
    
    return _totalMediaSize;
}

- (NSString *)objectTypeId {
    if (_objectTypeId == nil) {
        _objectTypeId = [self getFieldWithXPath:@"objectTypeIdFromEntry"];
    }
    
    return _objectTypeId;
}

- (id) getFieldWithXPath:(NSString *) fieldName {
    
    NSError *error;
    NSDictionary *dict = [SBTFileEntry namespacesForFileEntry];
    NSArray *list = [self.xmlDocument nodesForXPath:[self.xpathMap objectForKey:fieldName]
                                         namespaces:dict
                                              error:&error];
    // Check for an error
    if (error != nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
        
        return nil;
    }
    
    // Check if there is a result
    if (list == nil || [list count] == 0)
        return nil;
    
    return ((GDataXMLNode *)[list objectAtIndex:0]).stringValue;
}

+ (NSDictionary *) namespacesForFileEntry {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"http://www.ibm.com/xmlns/prod/sn" forKey:@"snx"];
    [dict setValue:@"http://www.w3.org/2005/Atom" forKey:@"a"];
    [dict setValue:@"urn:ibm.com/td" forKey:@"td"];
    [dict setValue:@"http://a9.com/-/spec/opensearch/1.1/" forKey:@"opensearch"];
    
    return dict;
}

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"File id: %@\n", self.fileId];
    description = [description stringByAppendingFormat:@"Creator id: %@\n", self.creatorId];
    description = [description stringByAppendingFormat:@"Label: %@\n", self.label];
    description = [description stringByAppendingFormat:@"Lock: %@\n", self.lock];
    description = [description stringByAppendingFormat:@"Library type: %@\n", self.libraryType];
    description = [description stringByAppendingFormat:@"Category: %@\n", self.category];
    description = [description stringByAppendingFormat:@"Total result: %@\n", self.totalResults];
    description = [description stringByAppendingFormat:@"Comment entry: %@\n", [self.commentEntry description]];
    description = [description stringByAppendingFormat:@"Person entry: %@\n", [self.personEntry description]];
    description = [description stringByAppendingFormat:@"Title: %@\n", self.title];
    description = [description stringByAppendingFormat:@"Summary: %@\n", self.summary];
    description = [description stringByAppendingFormat:@"Comments count: %d\n", [self.commentsCount intValue]];
    description = [description stringByAppendingFormat:@"Recommendations count: %d\n", [self.recommendationsCount intValue]];
    description = [description stringByAppendingFormat:@"Shares count: %d\n", [self.sharesCount intValue]];
    description = [description stringByAppendingFormat:@"Folders count: %d\n", [self.foldersCount intValue]];
    description = [description stringByAppendingFormat:@"Attachment count: %d\n", [self.attachmentsCount intValue]];
    description = [description stringByAppendingFormat:@"Versions count: %d\n", [self.versionsCount intValue]];
    description = [description stringByAppendingFormat:@"References count: %d\n", [self.referencesCount intValue]];
    description = [description stringByAppendingFormat:@"Published: %@\n", self.published];
    description = [description stringByAppendingFormat:@"Updated: %@\n", self.updated];
    description = [description stringByAppendingFormat:@"Created: %@\n", self.created];
    description = [description stringByAppendingFormat:@"Modified: %@\n", self.modified];
    description = [description stringByAppendingFormat:@"Last accessed: %@\n", self.lastAccessed];
    description = [description stringByAppendingFormat:@"Modifier: %@\n", [self.modifier description]];
    description = [description stringByAppendingFormat:@"Visibity: %@\n", self.visibility];
    description = [description stringByAppendingFormat:@"Library id: %@\n", self.libraryId];
    description = [description stringByAppendingFormat:@"Version label: %@\n", self.versionLabel];
    description = [description stringByAppendingFormat:@"Propogation: %@\n", self.propogation];
    description = [description stringByAppendingFormat:@"Total media size: %@\n", self.totalMediaSize];
    description = [description stringByAppendingFormat:@"Object type id: %@\n", self.objectTypeId];
    
    return description;
}

@end
