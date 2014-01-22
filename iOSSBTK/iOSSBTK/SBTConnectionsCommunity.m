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

//  This class represent the community object for connections

#import "SBTConnectionsCommunity.h"
#import "SBTConstants.h"
#import "FBLog.h"
#import "SBTUtils.h"

@interface SBTConnectionsCommunity ()

@property (strong, nonatomic) NSMutableDictionary *xpathMap;

@end

@implementation SBTConnectionsCommunity

@synthesize communityUuid = _communityUuid, parentCommunityUuid = _parentCommunityUuid, title = _title, communityType = _communityType, content = _content, communityUrl = _communityUrl, logoUrl = _logoUrl, summary = _summary, tags = _tags, memberCount = _memberCount, authorId = _authorId, contributorId = _contributorId, datePublished = _datePublished, dateUpdated = _dateUpdated;

- (id) init {
    if (self = [super init]) {
        [self initEnv];
    }
    
    return self;
}

- (id) initWithXMLDocument:(SBTXMLDocument *) document {
    if (self = [super init]) {
        self.xmlDocument = document;
        [self initEnv];
    }
    
    return self;
}

- (void) initEnv {
    self.fieldsDict = [[NSMutableDictionary alloc] init];
    self.xpathMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     @"/a:entry/snx:communityUuid", @"communityUuid",
                     @"/a:entry/a:link[@rel='http://www.ibm.com/xmlns/prod/sn/parentcommunity']/@href", @"parentCommunity",
                     @"/a:entry/a:summary[@type='text']", @"summary",
                     @"/a:entry/a:title", @"title",
                     @"/a:entry/a:link[@rel='http://www.ibm.com/xmlns/prod/sn/logo']/@href", @"logoUrl",
                     @"/a:entry/a:link[@rel='http://www.ibm.com/xmlns/prod/sn/member-list']/@href", @"membersUrl",
                     @"/a:entry/a:link[@rel='alternate']/@href", @"communityUrl",
                     @"/a:entry/a:link[@rel='self']/@href", @"communityAtomUrl",
                     @"/a:entry/a:category/@term", @"tags",
                     @"/a:entry/a:content[@type='html']", @"content",
                     @"/a:entry/snx:membercount", @"memberCount",
                     @"/a:entry/snx:communityType", @"communityType",
                     @"/a:entry/a:published", @"published",
                     @"/a:entry/a:updated", @"updated",
                     @"/a:entry/a:author/snx:userid", @"authorUid",
                     @"/a:entry/a:author/a:name", @"authorName",
                     @"/a:entry/a:author/a:email", @"authorEmail",
                     @"/a:entry/a:contributor/snx:userid", @"contributorUid",
                     @"/a:entry/a:contributor/a:name", @"contributorName",
                     @"/a:entry/a:contributor/a:email", @"contributorEmail",
                     nil];
}

- (NSString *) communityUuid {
    if (_communityUuid == nil) {
        _communityUuid = [self getFieldWithXPath:@"communityUuid"];
    }
    
    return _communityUuid;
}

- (NSString *)parentCommunityUuid {
    if (_parentCommunityUuid == nil) {
        NSString *link = [self getFieldWithXPath:@"parentCommunity"];
        if (link != nil) {
            NSRange range = [link rangeOfString:@"communityUuid="];
            NSString *communityUuid = [[link substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            _parentCommunityUuid = communityUuid;
        }
    }
    
    return _parentCommunityUuid;
}

- (NSString *) title {
    if (_title == nil) {
        _title = [self getFieldWithXPath:@"title"];
    }
    
    return _title;
}

- (NSString *) communityType {
    if (_communityType == nil) {
        _communityType = [self getFieldWithXPath:@"communityType"];
    }
    
    return _communityType;
}

- (NSString *) content {
    if (_content == nil) {
        _content = [self getFieldWithXPath:@"content"];
    }
    
    return _content;
}

- (void)setContent:(NSString *)content {
    _content = content;
    [self.fieldsDict setValue:content forKey:@"content"];
}

- (NSString *) communityUrl {
    if (_communityUrl == nil) {
        _communityUrl = [self getFieldWithXPath:@"communityAtomUrl"];
    }
    
    return _communityUrl;
}

- (NSString *) logoUrl {
    if (_logoUrl == nil) {
        _logoUrl = [self getFieldWithXPath:@"logoUrl"];
    }
    
    return _logoUrl;
}

- (NSString *) summary {
    if (_summary == nil) {
        _summary = [self getFieldWithXPath:@"summary"];
    }
    
    return _summary;
}

- (NSMutableArray *) tags {
    if (_tags == nil) {
        _tags = [self getFieldWithXPath:@"tags"];
    }
    
    return _tags;
}

- (void)setTags:(NSMutableArray *)tags {
    _tags = tags;
    [self.fieldsDict setValue:tags forKey:@"tags"];
}

- (NSNumber *) memberCount {
    if (_memberCount == nil) {
        _memberCount = [NSNumber numberWithInt:[[self getFieldWithXPath:@"memberCount"] intValue]];
    }
    
    return _memberCount;
}

- (NSString *) authorId {
    if (_authorId == nil) {
        _authorId = [self getFieldWithXPath:@"authorUid"];
    }
    
    return _authorId;
}

- (NSString *) contributorId {
    if (_contributorId == nil) {
        _contributorId = [self getFieldWithXPath:@"contributorUid"];
    }
    
    return _contributorId;
}

- (NSDate *) datePublished {
    if (_datePublished == nil) {
        NSString *str = [self getFieldWithXPath:@"published"];
        if (str != nil) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
            NSDate *pub = [df dateFromString:str];
            _datePublished = pub;
        }
    }
    
    return _datePublished;
}

- (NSDate *) dateUpdated {
    if (_dateUpdated == nil) {
        NSString *str = [self getFieldWithXPath:@"updated"];
        if (str != nil) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
            NSDate *pub = [df dateFromString:str];
            _dateUpdated = pub;
        }
    }
    
    return _dateUpdated;
}

- (id) getFieldWithXPath:(NSString *) fieldName {
    
    NSError *error;
    NSDictionary *dict = [SBTConnectionsCommunity namespacesForCommunity];
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
    
    if ([fieldName isEqualToString:@"tags"]) {
        NSMutableArray *listToReturn = [[NSMutableArray alloc] init];
        for (GDataXMLNode *node in list) {
            [listToReturn addObject:node.stringValue];
        }
        
        return listToReturn;
    }
    
    return ((GDataXMLNode *)[list objectAtIndex:0]).stringValue;
}

+ (NSDictionary *) namespacesForCommunity {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"http://www.ibm.com/xmlns/prod/sn" forKey:@"snx"];
    [dict setValue:@"http://www.w3.org/2005/Atom" forKey:@"a"];
    //[dict setValue:@"http://www.w3.org/1999/xhtml" forKey:@"b"];
    
    return dict;
}

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"CommunityUuid: %@\n", self.communityUuid];
    description = [description stringByAppendingFormat:@"ParentCommunityUuid: %@\n", self.parentCommunityUuid];
    description = [description stringByAppendingFormat:@"Title: %@\n", self.title];
    description = [description stringByAppendingFormat:@"Community Type: %@\n", self.communityType];
    description = [description stringByAppendingFormat:@"Content: %@\n", self.content];
    description = [description stringByAppendingFormat:@"Community url: %@\n", self.communityUrl];
    description = [description stringByAppendingFormat:@"Logo url: %@\n", self.logoUrl];
    description = [description stringByAppendingFormat:@"Summary: %@\n", self.summary];
    description = [description stringByAppendingFormat:@"Tags: %@\n", [self.tags description]];
    description = [description stringByAppendingFormat:@"Member count: %d\n", [self.memberCount intValue]];
    description = [description stringByAppendingFormat:@"Author id: %@\n", self.authorId];
    description = [description stringByAppendingFormat:@"Contributor id: %@\n", self.contributorId];
    description = [description stringByAppendingFormat:@"Date published: %@\n", [self.datePublished description]];
    description = [description stringByAppendingFormat:@"Date updated: %@\n", [self.dateUpdated description]];
    
    return description;
}

- (NSString *) constructRequestBody {
    NSString *requestBody = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:app=\"http://www.w3.org/2007/app\" xmlns:snx=\"http://www.ibm.com/xmlns/prod/sn\">";
    for (NSString *key in self.fieldsDict) {
        if ([key isEqualToString:@"title"]) {
            requestBody = [requestBody stringByAppendingFormat:@"<title type=\"text\">%@</title>", [self.fieldsDict objectForKey:key]];
        } else if ([key isEqualToString:@"content"]) {
            requestBody = [requestBody stringByAppendingFormat:@"<content type=\"html\">%@</content>", [self.fieldsDict objectForKey:key]];
        } else if ([key isEqualToString:@"communityType"]) {
            requestBody = [requestBody stringByAppendingFormat:@"<snx:communityType>%@</snx:communityType>", [self.fieldsDict objectForKey:key]];
        } else if ([key isEqualToString:@"tags"]) {
            
            NSMutableArray *tags = [self.fieldsDict objectForKey:key];
            for (NSString *tag in tags) {
                requestBody = [requestBody stringByAppendingFormat:@"<category term=\"%@\"/>", tag];
            }
        }
    }
    
    // Title and content are mandatory fields...
    if ([requestBody rangeOfString:@"title"].location == NSNotFound) {
        requestBody = [requestBody stringByAppendingFormat:@"<title type=\"text\">%@</title>", self.title];
    }
    
    if ([requestBody rangeOfString:@"content"].location == NSNotFound) {
        requestBody = [requestBody stringByAppendingFormat:@"<content type=\"text\">%@</content>", self.content];
    }
    
    if ([requestBody rangeOfString:@"communityType"].location == NSNotFound) {
        NSString *communityType = (self.communityType != nil) ? self.communityType : @"private";
        requestBody = [requestBody stringByAppendingFormat:@"<snx:communityType>%@</snx:communityType>", communityType];
    }
    
    // If there is a parent community then add the link to it to the body
    if (self.parentCommunityUuid != nil) {
        requestBody = [requestBody stringByAppendingFormat:@"<link rel=\"http://www.ibm.com/xmlns/prod/sn/parentcommunity\" href=\"%@/communities/service/atom/community/instance?communityUuid=%@\"></link>", [SBTUtils getUrlForEndPoint:@"connections"], self.parentCommunityUuid];
    }
    
    
    requestBody = [requestBody stringByAppendingString:@"<category term=\"community\" scheme=\"http://www.ibm.com/xmlns/prod/sn/type\"></category></entry>"];
    
    return requestBody;
}


@end
