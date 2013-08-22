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

#import "IBMCommunityForumTopic.h"
#import "IBMConstants.h"
#import "FBLog.h"

@interface IBMCommunityForumTopic ()

@property (strong, nonatomic) NSMutableDictionary *xpathMap;

@end

@implementation IBMCommunityForumTopic

@synthesize fId = _fId, title = _title, summary = _summary;

- (id) init {
    if (self = [super init]) {
        [self initEnv];
    }
    
    return self;
}

- (id) initWithXMLDocument:(IBMXMLDocument *)document {
    if (self = [super init]) {
        [self initEnv];
        self.xmlDocument = document;
    }
    
    return self;
}

- (void) initEnv {
    self.fieldsDict = [[NSMutableDictionary alloc] init];
    self.xpathMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     @"/a:entry/a:id", @"fId",
                     @"/a:entry/a:title", @"title",
                     @"/a:entry/a:contributor/a:email", @"email",
                     @"/a:entry/a:summary[@type='text']", @"summary",
                     nil];
}

- (NSString *)fId {
    if (_fId == nil) {
        _fId = [self getFieldWithXPath:@"fId"];
    }
    
    return _fId;
}

- (NSString *)title {
    if (_title == nil) {
        _title = [self getFieldWithXPath:@"title"];
    }
    
    return _title;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.fieldsDict setValue:title forKey:@"title"];
}

- (NSString *)summary {
    if (_summary == nil) {
        _summary = [self getFieldWithXPath:@"summary"];
    }
    
    return _summary;
}

- (void)setSummary:(NSString *)summary {
    _summary = summary;
    [self.fieldsDict setValue:summary forKey:@"summary"];
}

- (id) getFieldWithXPath:(NSString *) fieldName {
    
    NSError *error;
    NSDictionary *dict = [IBMCommunityForumTopic namespacesForCommunityForumTopic];
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

+ (NSDictionary *) namespacesForCommunityForumTopic {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"http://www.ibm.com/xmlns/prod/sn" forKey:@"snx"];
    [dict setValue:@"http://www.w3.org/2005/Atom" forKey:@"a"];
    
    return dict;
}

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"Id: %@\n", self.fId];
    description = [description stringByAppendingFormat:@"Title: %@\n", self.title];
    description = [description stringByAppendingFormat:@"Summary: %@\n", self.summary];
    
    return description;
}

@end
