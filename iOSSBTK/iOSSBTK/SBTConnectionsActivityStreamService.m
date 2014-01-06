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

//  This class serves as the api service for connections activity stream including getting,
//  searching and updating.

#import "SBTConnectionsActivityStreamService.h"
#import "SBTConstants.h"
#import "FBLog.h"

@implementation SBTConnectionsActivityStreamService

const NSString *OPENSOCIAL_URL = @"/connections/opensocial";
const NSString *ROLLUP = @"rollup";
const NSString *BROADCAST = @"broadcast";
const NSString *LANG = @"lang";
const NSString *FILTERBY = @"FilterBy";
const NSString *FILTEROP = @"filterOp";
const NSString *FILTERVALUE = @"filterValue";
const NSString *QUERY = @"query";
const NSString *QUERYLANGUAGE = @"queryLanguage";
const NSString *FILTERS = @"filters";
const NSString *DATAFILTER = @"dateFilter";
const NSString *FACETREQUESTS = @"facetRequests";
const NSString *PREFERSEARCHINDEX = @"preferSearchIndex";
const NSString *CUSTOM = @"custom"; //indicates user passed in the search string

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

- (void) getActivityStreamsWithParameters:(NSMutableDictionary *) parameters
                            fromUserType:(NSString *) user
                               groupType:(NSString *) group
                                 appType:(NSString *) app
                                 success:(void (^)(NSMutableArray *)) success
                                 failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Retrieving activity stream"] from:self];
    
    if ([app isEqualToString:[SBTASApplication convertToString:A_NOAPP]])
        app = @"";
    
    
    // Put parameters into a dictionary
    NSString *path = [NSString stringWithFormat:@"%@/%@/rest/activitystreams/%@/%@/%@",
                      OPENSOCIAL_URL,
                      [self.endPoint getAuthType],
                      user,
                      group,
                      app];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_JSON
                                            success:^(id response, id result) {
                                                NSMutableArray *list = [self convertToActivityStreamEntriesFromJSON:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getMyStatusUpdatesWithParameters:(NSMutableDictionary *) parameters
                                 success:(void (^)(NSMutableArray *)) success
                                 failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my status updates with parameters: %@", [parameters description]] from:self];
    
    [self getActivityStreamsWithParameters:parameters
                             fromUserType:[SBTASUser convertToString:U_ME]
                                groupType:[SBTASGroup convertToString:G_ALL]
                                  appType:[SBTASApplication convertToString:A_STATUS]
                                  success:^(NSMutableArray *list) {
                                      success(list);
                                  } failure:^(NSError *error) {
                                      failure(error);
                                  }];
}

- (void) getAllUpdatesWithParameters:(NSMutableDictionary *) parameters
                             success:(void (^)(NSMutableArray *)) success
                             failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting all updates with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:@"true" forKey: (NSString *) ROLLUP];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_PUBLIC]
                                 groupType:[SBTASGroup convertToString:G_ALL]
                                   appType:[SBTASApplication convertToString:A_ALL]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getUpdatesFromMyNetworkWithParameters:(NSMutableDictionary *) parameters
                                       success:(void (^)(NSMutableArray *)) success
                                       failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting updates from my network with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:@"true" forKey: (NSString *) ROLLUP];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_FRIENDS]
                                   appType:[SBTASApplication convertToString:A_ALL]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getStatusUpdatesFromMyNetworkWithParameters:(NSMutableDictionary *) parameters
                                       success:(void (^)(NSMutableArray *)) success
                                       failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting status updates from my network with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:@"true" forKey: (NSString *) ROLLUP];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_FRIENDS]
                                   appType:[SBTASApplication convertToString:A_STATUS]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getUpdatesFromPeopleIFollowWithParameters:(NSMutableDictionary *) parameters
                                             success:(void (^)(NSMutableArray *)) success
                                             failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting updates from people I follow with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:@"true" forKey: (NSString *) ROLLUP];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_FOLLOWING]
                                   appType:[SBTASApplication convertToString:A_STATUS]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getUpdatesFromCommunitiesIFollowWithParameters:(NSMutableDictionary *) parameters
                                           success:(void (^)(NSMutableArray *)) success
                                           failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting updates from communities I follow with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:@"true" forKey: (NSString *) ROLLUP];
    [parameters setValue:@"true" forKey: (NSString *) BROADCAST];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_ALL]
                                   appType:[SBTASApplication convertToString:A_COMMUNITIES]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getUpdatesFromUserWithUserId:(NSString *) userId
                           parameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting updates from a user: %@ with parameters: %@", userId, [parameters description]] from:self];
    
    if (userId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"userId is nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"userId cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:userId
                                 groupType:[SBTASGroup convertToString:G_INVOLVED]
                                   appType:[SBTASApplication convertToString:A_ALL]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getUpdatesFromCommunityWithCommunityId:(NSString *) communityId
                                     parameters:(NSMutableDictionary *) parameters
                                        success:(void (^)(NSMutableArray *)) success
                                        failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting updates from a community: %@ with parameters: %@", communityId, [parameters description]] from:self];
    
    if (communityId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"communityId is nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"communityId cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[NSString stringWithFormat:@"%@%@", [SBTASUser convertToString:U_COMMUNITY], communityId]
                                 groupType:[SBTASGroup convertToString:G_ALL]
                                   appType:[SBTASApplication convertToString:A_NOAPP]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getNotificationsForMeWithParameters:(NSMutableDictionary *) parameters
                                     success:(void (^)(NSMutableArray *)) success
                                     failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting notifications for me with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_NOTESFORME]
                                   appType:[SBTASApplication convertToString:A_NOAPP]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getResponsesToMyContentWithParameters:(NSMutableDictionary *) parameters
                                       success:(void (^)(NSMutableArray *)) success
                                       failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting responses to my content with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_RESPONSES]
                                   appType:[SBTASApplication convertToString:A_NOAPP]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getMyActionableViewWithParameters:(NSMutableDictionary *) parameters
                                   success:(void (^)(NSMutableArray *)) success
                                   failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my actionable view with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_ACTION]
                                   appType:[SBTASApplication convertToString:A_NOAPP]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getMyActionableViewForApplication:(NSString *) app
                                parameters:(NSMutableDictionary *) parameters
                                   success:(void (^)(NSMutableArray *)) success
                                   failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting actionable view for application: %@ with parameters: %@", app, [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_ACTION]
                                   appType:app
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) getMySavedViewWithParameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my saved view with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_SAVED]
                                   appType:[SBTASApplication convertToString:A_NOAPP]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];

}

- (void) getMySavedViewForApplication:(NSString *) app
                           parameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my saved view for application: %@ with parameters: %@", app, [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_SAVED]
                                   appType:app
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) searchForQuery:(NSString *) query
             parameters:(NSMutableDictionary *) parameters
                success:(void (^)(NSMutableArray *)) success
                failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Search for a query: %@ with parameters: %@", query, [parameters description]] from:self];
    
    if (query == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"query is nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"query cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:query forKey: (NSString *) QUERY];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_PUBLIC]
                                 groupType:[SBTASGroup convertToString:G_ALL]
                                   appType:[SBTASApplication convertToString:A_ALL]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) searchForTags:(NSString *) tags
            parameters:(NSMutableDictionary *) parameters
               success:(void (^)(NSMutableArray *)) success
               failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Search for tags: %@ with parameters: %@", tags, [parameters description]] from:self];
    
    if (tags == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"tags is nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"tags cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:@"true" forKey: (NSString *) ROLLUP];
    
    if ([tags rangeOfString:@","].location == NSNotFound) {
        [parameters setValue:[NSString stringWithFormat:@"[{'type':'tag','values':['%@']}]", tags]
                      forKey: (NSString *) FILTERS];
    } else {
        bool separate = NO;
        NSString *modQuery = @"";
        NSArray *parts = [tags componentsSeparatedByString:@","];
        for (NSString *tag in parts) {
            if (separate == YES)
                modQuery = [modQuery stringByAppendingFormat:@","];
            
            modQuery = [modQuery stringByAppendingFormat:@"'%@'", tag];
            separate = YES;
        }
        
        [parameters setValue:[NSString stringWithFormat:@"[{'type':'tag','values':[%@]}]", modQuery]
                      forKey:(NSString *) FILTERS];
    }
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_PUBLIC]
                                 groupType:[SBTASGroup convertToString:G_ALL]
                                   appType:[SBTASApplication convertToString:A_ALL]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) searchByFilters:(NSString *) filterType
                   query:(NSString *) query
              parameters:(NSMutableDictionary *) parameters
                 success:(void (^)(NSMutableArray *)) success
                 failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Search by filters: %@ with query: %@ with parameters: %@", filterType, query, [parameters description]] from:self];
    
    if (filterType == nil || query == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"filterType or query is nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Filter type and query cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:@"true" forKey: (NSString *) ROLLUP];
    [parameters setValue:query forKey: (NSString *) QUERY];
    [parameters setValue:filterType forKey: (NSString *) FILTERS];
    
    /*if ([query rangeOfString:@","].location == NSNotFound) {
        [parameters setValue:[NSString stringWithFormat:@"[{'type':'%@','values':['%@']}]", filterType, query] forKey: (NSString *) FILTERS];
    } else {
        bool separate = NO;
        NSString *modQuery = @"";
        NSArray *parts = [query componentsSeparatedByString:@","];
        for (NSString *q in parts) {
            if (separate == YES)
                modQuery = [modQuery stringByAppendingFormat:@","];
            
            modQuery = [modQuery stringByAppendingFormat:@"'%@'", q];
            separate = YES;
        }
        
        [parameters setValue:[NSString stringWithFormat:@"[{'type':'%@','values':[%@]}]", filterType, modQuery] forKey:(NSString *) FILTERS];
    }*/
    
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_ME]
                                 groupType:[SBTASGroup convertToString:G_ALL]
                                   appType:[SBTASApplication convertToString:A_ALL]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) searchWithPattern:(NSString *) searchPattern
                parameters:(NSMutableDictionary *) parameters
                   success:(void (^)(NSMutableArray *)) success
                   failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Search with pattern: %@ with parameters: %@", searchPattern, [parameters description]] from:self];
    
    if (searchPattern == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"searchPattern is nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"searchPattern cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:[self getUserLanguage] forKey: (NSString *) LANG];
    [parameters setValue:@"true" forKey: (NSString *) ROLLUP];
    [parameters setValue:searchPattern forKey: (NSString *) CUSTOM];
    
    [self getActivityStreamsWithParameters:parameters
                              fromUserType:[SBTASUser convertToString:U_PUBLIC]
                                 groupType:[SBTASGroup convertToString:G_ALL]
                                   appType:[SBTASApplication convertToString:A_ALL]
                                   success:^(NSMutableArray *list) {
                                       success(list);
                                   } failure:^(NSError *error) {
                                       failure(error);
                                   }];
}

- (void) postEntryWithUserType:(AS_USER_TYPE) user
                     groupType:(AS_GROUP_TYPE) group
                       appType:(AS_APPLICATION_TYPE) app
                   jsonPayload:(NSDictionary *) jsonPayload
                    parameters:(NSMutableDictionary *) parameters
                       success:(void (^)(id)) success
                       failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Post entry with jsonPayload: %@ parameters: %@", jsonPayload, [parameters description]] from:self];
    
    if (jsonPayload == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"jsonPayload is nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"jsonPayload cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/json", @"Content-Type",
                                    nil];
    
    NSError *jsonError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonPayload
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&jsonError];
    if (jsonError != nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"Error while constructing json data: %@", [jsonError description]] from:self];
        return;
    }
    
    [parameters setObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:@"body"];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/rest/activitystreams/%@/%@/%@",
                      OPENSOCIAL_URL,
                      [self.endPoint getAuthType],
                      [SBTASUser convertToString:user],
                      [SBTASGroup convertToString:group],
                      [SBTASApplication convertToString:app]];
    [[self getClientService] initPostRequestWithPath:path
                                             headers:headers
                                          parameters:parameters
                                              format:RESPONSE_JSON
                                             success:^(id response, id result) {
                                                 success(result);
                                             } failure:^(id response, NSError *error) {
                                                 failure(error);
                                             }];
}

- (void) postEntry:(NSDictionary *) jsonPayload
        parameters:(NSMutableDictionary *) parameters
           success:(void (^)(id)) success
           failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Post entry with jsonPayload: %@ parameters: %@", jsonPayload, [parameters description]] from:self];
    
    if (jsonPayload == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"jsonPayload is nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"jsonPayload cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/json", @"Content-Type",
                                    nil];
    NSError *jsonError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonPayload
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&jsonError];
    if (jsonError != nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"Error while constructing json data: %@", [jsonError description]] from:self];
        return;
    }
    
    [parameters setObject:data forKey:@"body"];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/rest/activitystreams/%@/%@/%@",
                      OPENSOCIAL_URL,
                      [self.endPoint getAuthType],
                      [SBTASUser convertToString:U_ME],
                      [SBTASGroup convertToString:G_ALL],
                      [SBTASApplication convertToString:A_ALL]];
    [[self getClientService] initPostRequestWithPath:path
                                             headers:headers
                                          parameters:parameters
                                              format:RESPONSE_JSON
                                             success:^(id response, id result) {
                                                 success(result);
                                             } failure:^(id response, NSError *error) {
                                                 failure(error);
                                             }];
}

- (void) postMBEntryUserType:(NSString *) user
                   groupType:(NSString *) group
                     appType:(NSString *) app
                     payload:(NSDictionary *) jsonPayload
                     success:(void (^)(id)) success
                     failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK) {
        [FBLog log:[NSString stringWithFormat:@"Post microblog entry with jsonPayload: %@", jsonPayload] from:self];
    }
    
    /*if (jsonPayload == nil) {
        [FBLog log:[NSString stringWithFormat:@"jsonPayload is nil"] from:self];
        failure([NSError errorWithDomain:@"IBMConnectionActivityStreamService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"jsonPayload cannot be nil", @"description", nil]]);
        return;
    }*/
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/json", @"Content-Type",
                                    nil];
    NSData *data;
    if (jsonPayload != nil) {
        NSError *jsonError;
        data = [NSJSONSerialization dataWithJSONObject:jsonPayload
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError];
        if (jsonError != nil) {
            if (IS_DEBUGGING_SBTK) {
                [FBLog log:[NSString stringWithFormat:@"Error while constructing json data: %@", [jsonError description]] from:self];
            }
            return;
        }
        
        [parameters setObject:data forKey:@"body"];
    } else {
        data = nil;
    }
    
    if (user == nil)
        user = [SBTASUser convertToString:U_ME];
    if (group == nil)
        group = [SBTASGroup convertToString:G_ALL];
    if (app == nil)
        app = @"";
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/rest/ublog/%@/%@/%@",
                      OPENSOCIAL_URL,
                      [self.endPoint getAuthType],
                      user,
                      group,
                      app];
    [[self getClientService] initPostRequestWithPath:path
                                             headers:headers
                                          parameters:parameters
                                              format:RESPONSE_JSON
                                             success:^(id response, id result) {
                                                 success(result);
                                             } failure:^(id response, NSError *error) {
                                                 failure(error);
                                             }];
}

#pragma mark - helper methods

- (NSMutableArray *) convertToActivityStreamEntriesFromJSON:(NSMutableDictionary *) json {
    NSMutableArray *listOfEntriesToReturn = [[NSMutableArray alloc] init];
    NSMutableArray *listOfEntries = [json objectForKey:@"list"];
    if (listOfEntries != nil && [listOfEntries count] > 0) {
        for (NSMutableDictionary *entry in listOfEntries) {
            SBTActivityStreamEntry *streamEntry = [SBTActivityStreamEntry createActivityStreamEntryObjectFromDictionary:entry];
            [listOfEntriesToReturn addObject:streamEntry];
        }
    }
    
    return listOfEntriesToReturn;
}

- (NSString *) getUserLanguage {
    return @"en";
}

@end
