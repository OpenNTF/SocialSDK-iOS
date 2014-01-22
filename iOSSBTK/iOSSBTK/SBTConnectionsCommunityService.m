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

//  This class is a service api to access community resources of connections

#import "SBTConnectionsCommunityService.h"
#import "SBTConstants.h"
#import "FBLog.h"

@implementation SBTConnectionsCommunityService

const NSString *COMMUNITY_URL = @"/communities";

- (id) init {
    if (self = [super initWithEndPointName:@"connections"]) {
        
    }
    
    return self;
}

- (id) initWithEndPointName:(NSString *)endPointName {
    if (self = [super initWithEndPointName:endPointName]) {
        
    }
    
    return self;
}

#pragma mark - API Services

- (void) getCommunityWithUuid:(NSString *) uuid
                      success:(void (^)(SBTConnectionsCommunity *)) success
                      failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Retrieving a community with uuid: %@", uuid] from:self];
    
    if (uuid == nil) {
        return;// Return error here
    }
    
    // Put parameters into a dictionary
    NSMutableDictionary *dict;
    dict = [NSMutableDictionary dictionaryWithObject:uuid forKey:@"communityUuid"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/service/atom%@/community/instance", COMMUNITY_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:dict
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                SBTConnectionsCommunity *community = [[SBTConnectionsCommunity alloc] initWithXMLDocument:result];
                                                success(community);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) createCommunity:(SBTConnectionsCommunity *) community
                 success:(void (^)(SBTConnectionsCommunity *)) success
                 failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Creating a community: %@", [community description]] from:self];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"application/atom+xml", @"Content-Type",
                             nil];
    NSString *body = [community constructRequestBody];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:body forKey:@"body"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/service/atom%@/communities/my", COMMUNITY_URL, auth];
    [[self getClientService] initPostRequestWithPath:urlStr
                                            headers:headers
                                         parameters:params
                                             format:RESPONSE_NONE
                                            success:^(id response, id result) {
                                                // Retrieve the community link from the response
                                                NSString *communityLink = [((NSHTTPURLResponse *) response).allHeaderFields objectForKey:@"Location"];
                                                // Parse the communityUuid
                                                NSRange range = [communityLink rangeOfString:@"communityUuid="];
                                                NSString *communityUuid = [[communityLink substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                
                                                // Retrieve the community from scratch
                                                [self getCommunityWithUuid:communityUuid success:^(SBTConnectionsCommunity *comm) {
                                                    [community.fieldsDict removeAllObjects];
                                                    success(comm);
                                                } failure:^(NSError *error) {
                                                    failure(error);
                                                }];
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) updateCommunity:(SBTConnectionsCommunity *) community
                 success:(void (^)(BOOL)) success
                 failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Updating a community: %@", [community description]] from:self];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"application/atom+xml", @"Content-Type",
                             nil];
    NSString *body = [community constructRequestBody];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   community.communityUuid, @"communityUuid",
                                   nil];
    
    [params setObject:body forKey:@"body"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/service/atom%@/community/instance", COMMUNITY_URL, auth];
    [[self getClientService] initPutRequestWithPath:urlStr
                                            headers:headers
                                         parameters:params
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                [community.fieldsDict removeAllObjects];
                                                success(YES);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) deleteCommunity:(SBTConnectionsCommunity *) community
                 success:(void (^)(BOOL)) success
                 failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Deleting a community: %@", [community description]] from:self];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:community.communityUuid, @"communityUuid", nil];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/service/atom%@/community/instance",
                        COMMUNITY_URL,
                        auth];
    [[self getClientService] initDeleteRequestWithPath:urlStr
                                         parameters:params
                                             format:RESPONSE_NONE
                                            success:^(id response, id result) {
                                                [community.fieldsDict removeAllObjects];
                                                success(YES);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getMyCommunitiesWithSuccess:(void (^)(NSMutableArray *)) success
                             failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Retrieving my communities"] from:self];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/service/atom%@/communities/my",
                      COMMUNITY_URL,
                      auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:nil
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                NSMutableArray *list = [self convertToCommunityListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getPublicCommunitiesWithParameters:(NSMutableDictionary *) params
                                    success:(void (^)(NSMutableArray *)) success
                                    failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Retrieving public communities"] from:self];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/service/atom%@/communities/all", COMMUNITY_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:params
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                NSMutableArray *list = [self convertToCommunityListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) createSubCommunity:(SBTConnectionsCommunity *) subCommunity
               forCommunity:(SBTConnectionsCommunity *) community
                    success:(void (^)(SBTConnectionsCommunity *)) success
                    failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Creating a subcommunity %@ under community: %@", [subCommunity description], [community description]] from:self];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"application/atom+xml", @"Content-Type",
                             nil];
    subCommunity.parentCommunityUuid = community.communityUuid;
    NSString *body = [subCommunity constructRequestBody];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:body forKey:@"body"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/service/atom%@/communities/my", COMMUNITY_URL, auth];
    [[self getClientService] initPostRequestWithPath:urlStr
                                             headers:headers
                                          parameters:params
                                              format:RESPONSE_NONE
                                             success:^(id response, id result) {
                                                 
                                                 // Retrieve the community link from the response
                                                 NSString *communityLink = [((NSHTTPURLResponse *) response).allHeaderFields objectForKey:@"Location"];
                                                 // Parse the communityUuid
                                                 NSRange range = [communityLink rangeOfString:@"communityUuid="];
                                                 NSString *communityUuid = [[communityLink substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                 
                                                 // Retrieve the community from scratch
                                                 [self getCommunityWithUuid:communityUuid success:^(SBTConnectionsCommunity *comm) {
                                                     [subCommunity.fieldsDict removeAllObjects];
                                                     success(comm);
                                                 } failure:^(NSError *error) {
                                                     failure(error);
                                                 }];
                                             } failure:^(id response, NSError * error) {
                                                 failure(error);
                                             }];
}

- (void) getSubCommunitiesForCommunity:(SBTConnectionsCommunity *) community
                            parameters:(NSMutableDictionary *) params
                               success:(void (^)(NSMutableArray *)) success
                               failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Retrieving sub communities for the community: %@", [community description]] from:self];
    
    if (params == nil) {
        params = [[NSMutableDictionary alloc] init];
    }
    
    [params setValue:community.communityUuid forKey:@"communityUuid"];
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/service/atom%@/community/subcommunities", COMMUNITY_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:params
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                NSMutableArray *list = [self convertToCommunityListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getMembersForCommunity:(SBTConnectionsCommunity *) community
                        success:(void (^)(NSMutableArray *)) success
                        failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Retrieving community members for the community: %@", [community description]] from:self];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:community.communityUuid forKey:@"communityUuid"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/service/atom%@/community/members", COMMUNITY_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:params
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                NSMutableArray *list = [self convertToCommunityMembersWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) addMember:(SBTCommunityMember *) member
     fromCommunity:(SBTConnectionsCommunity *) community
           success:(void (^)(BOOL)) success
           failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Adding member: %@ to the community: %@", [member description], [community description]] from:self];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/atom+xml", @"Content-Type",
                                    nil];
    NSString *body = [member constructRequestBody];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:body forKey:@"body"];
    [params setValue:community.communityUuid forKey:@"communityUuid"];
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/service/atom%@/community/members", COMMUNITY_URL, auth];
    [[self getClientService] initPostRequestWithPath:urlStr
                                             headers:headers
                                          parameters:params
                                              format:RESPONSE_NONE
                                             success:^(id response, id result) {
                                                 success(YES);
                                             } failure:^(id response, NSError * error) {
                                                 failure(error);
                                             }];
    
}

- (void) deleteMember:(SBTCommunityMember *) member
        fromCommunity:(SBTConnectionsCommunity *) community
              success:(void (^)(BOOL)) success
              failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Deleting the member: %@ from community: %@",[member description], [community description]] from:self];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   community.communityUuid, @"communityUuid",
                                   member.userId, ([SBTUtils isEmail:member.userId]?@"email":@"userid"),
                                   nil];
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/service/atom%@/community/members", COMMUNITY_URL, auth];
    [[self getClientService] initDeleteRequestWithPath:urlStr
                                            parameters:params
                                                format:RESPONSE_NONE
                                               success:^(id response, id result) {
                                                   [community.fieldsDict removeAllObjects];
                                                   success(YES);
                                               } failure:^(id response, NSError * error) {                                                   
                                                   failure(error);
                                               }];
}

- (void) getBookmarksForCommunity:(SBTConnectionsCommunity *) community
                          success:(void (^)(NSMutableArray *)) success
                          failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Retrieving bookmarks for the community: %@", [community description]] from:self];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:community.communityUuid forKey:@"communityUuid"];
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/service/atom%@/community/bookmarks", COMMUNITY_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:params
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                NSMutableArray *list = [self convertToCommunityBookmarksWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getForumTopicsForCommunity:(SBTConnectionsCommunity *) community
                            success:(void (^)(NSMutableArray *)) success
                            failure:(void (^)(NSError *)) failure {
 
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Retrieving forum topics for the community: %@", [community description]] from:self];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:community.communityUuid forKey:@"communityUuid"];
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/service/atom%@/community/forum/topics", COMMUNITY_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:params
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                NSMutableArray *list = [self convertToCommunityForumTopicsWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

#pragma mark - auxilary methods

- (NSString *) getAuthType {
    return [self.endPoint getAuthType];
}

- (NSMutableArray *) convertToCommunityListWithXML:(SBTXMLDocument *) document {
    
    NSMutableArray *listOfCommunity = nil;
    if (document != nil) {
        NSError *error;
        NSDictionary *dict = [SBTConnectionsCommunity namespacesForCommunity];
        NSArray *entryList = [document nodesForXPath:@"/a:feed/a:entry" namespaces:dict error:&error];
        if (entryList != nil && [entryList count] > 0) {
            
            listOfCommunity = [[NSMutableArray alloc] init];
            for (GDataXMLElement *element in entryList) {
                element.namespaces = document.rootElement.namespaces;
                // Make it a xml document
                SBTXMLDocument *doc = [[SBTXMLDocument alloc] initWithRootElement:element];
                // Create a profile object and add it to the array
                SBTConnectionsCommunity *comm = [[SBTConnectionsCommunity alloc] initWithXMLDocument:doc];
                [listOfCommunity addObject:comm];
            }
        }
    }
    
    return listOfCommunity;
}

- (NSMutableArray *) convertToCommunityMembersWithXML:(SBTXMLDocument *) document {
    
    NSMutableArray *listOfCommunityMembers = nil;
    if (document != nil) {
        NSError *error;
        NSDictionary *dict = [SBTConnectionsCommunity namespacesForCommunity];
        NSArray *entryList = [document nodesForXPath:@"/a:feed/a:entry" namespaces:dict error:&error];
        if (entryList != nil && [entryList count] > 0) {
            
            listOfCommunityMembers = [[NSMutableArray alloc] init];
            for (GDataXMLElement *element in entryList) {
                element.namespaces = document.rootElement.namespaces;
                // Make it a xml document
                SBTXMLDocument *doc = [[SBTXMLDocument alloc] initWithRootElement:element];
                // Create a profile object and add it to the array
                SBTCommunityMember *comm = [[SBTCommunityMember alloc] initWithXMLDocument:doc];
                [listOfCommunityMembers addObject:comm];
            }
        }
    }
    
    return listOfCommunityMembers;
}

- (NSMutableArray *) convertToCommunityBookmarksWithXML:(SBTXMLDocument *) document {
    
    NSMutableArray *listOfCommunityBookmarks = nil;
    if (document != nil) {
        NSError *error;
        NSDictionary *dict = [SBTConnectionsCommunity namespacesForCommunity];
        NSArray *entryList = [document nodesForXPath:@"/a:feed/a:entry" namespaces:dict error:&error];
        if (entryList != nil && [entryList count] > 0) {
            
            listOfCommunityBookmarks = [[NSMutableArray alloc] init];
            for (GDataXMLElement *element in entryList) {
                element.namespaces = document.rootElement.namespaces;
                // Make it a xml document
                SBTXMLDocument *doc = [[SBTXMLDocument alloc] initWithRootElement:element];
                // Create a profile object and add it to the array
                SBTCommunityBookmark *bookmark = [[SBTCommunityBookmark alloc] initWithXMLDocument:doc];
                [listOfCommunityBookmarks addObject:bookmark];
            }
        }
    }
    
    return listOfCommunityBookmarks;
}

- (NSMutableArray *) convertToCommunityForumTopicsWithXML:(SBTXMLDocument *) document {
    
    NSMutableArray *listOfCommunityForumTopics = nil;
    if (document != nil) {
        NSError *error;
        NSDictionary *dict = [SBTConnectionsCommunity namespacesForCommunity];
        NSArray *entryList = [document nodesForXPath:@"/a:feed/a:entry" namespaces:dict error:&error];
        if (entryList != nil && [entryList count] > 0) {
            
            listOfCommunityForumTopics = [[NSMutableArray alloc] init];
            for (GDataXMLElement *element in entryList) {
                element.namespaces = document.rootElement.namespaces;
                // Make it a xml document
                SBTXMLDocument *doc = [[SBTXMLDocument alloc] initWithRootElement:element];
                // Create a profile object and add it to the array
                SBTCommunityForumTopic *fTopic = [[SBTCommunityForumTopic alloc] initWithXMLDocument:doc];
                [listOfCommunityForumTopics addObject:fTopic];
            }
        }
    }
    
    return listOfCommunityForumTopics;
}

@end
