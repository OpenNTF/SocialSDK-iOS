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

#import "SBTBaseService.h"
#import "SBTActivityStreamEntry.h"
#import "SBTASUser.h"
#import "SBTASGroup.h"
#import "SBTASApplication.h"

@interface SBTConnectionsActivityStreamService : SBTBaseService

#pragma mark - properties


#pragma mark - methods

- (id) init;
- (id) initWithEndPointName:(NSString *)endPointName;

/**
 Get activitiy streams
 @param parameters: to be used when contructing the url
 @param user: User type. If nil passed @me will be used
 @param group: Group type. If nil passed @all will be used
 @param app: Application type. If nil passed @all will be used
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getActivityStreamsWithParameters:(NSMutableDictionary *) parameters
                            fromUserType:(NSString *) user
                               groupType:(NSString *) group
                                 appType:(NSString *) app
                                 success:(void (^)(NSMutableArray *)) success
                                 failure:(void (^)(NSError *)) failure;

/**
 Get my status updates
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getMyStatusUpdatesWithParameters:(NSMutableDictionary *) parameters
                                 success:(void (^)(NSMutableArray *)) success
                                 failure:(void (^)(NSError *)) failure;
/**
 Get all updates from activity stream
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getAllUpdatesWithParameters:(NSMutableDictionary *) parameters
                                 success:(void (^)(NSMutableArray *)) success
                                 failure:(void (^)(NSError *)) failure;

/**
 Get all updates from my network
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getUpdatesFromMyNetworkWithParameters:(NSMutableDictionary *) parameters
                             success:(void (^)(NSMutableArray *)) success
                             failure:(void (^)(NSError *)) failure;

/**
 Get all status updates from my network
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getStatusUpdatesFromMyNetworkWithParameters:(NSMutableDictionary *) parameters
                                       success:(void (^)(NSMutableArray *)) success
                                       failure:(void (^)(NSError *)) failure;

/**
 Get all updates from people I follow
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getUpdatesFromPeopleIFollowWithParameters:(NSMutableDictionary *) parameters
                                             success:(void (^)(NSMutableArray *)) success
                                             failure:(void (^)(NSError *)) failure;

/**
 Get all updates from communities I follow
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getUpdatesFromCommunitiesIFollowWithParameters:(NSMutableDictionary *) parameters
                                                 success:(void (^)(NSMutableArray *)) success
                                                 failure:(void (^)(NSError *)) failure;

/**
 Get updates from a user
 @param userId: id of the user
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getUpdatesFromUserWithUserId:(NSString *) userId
                           parameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure;


/**
 Get updates from a community
 @param communityId: id of the community
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getUpdatesFromCommunityWithCommunityId:(NSString *) communityId
                           parameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure;


/**
 Get notifications for me
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getNotificationsForMeWithParameters:(NSMutableDictionary *) parameters
                                                success:(void (^)(NSMutableArray *)) success
                                                failure:(void (^)(NSError *)) failure;

/**
 Get responses for my content
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getResponsesToMyContentWithParameters:(NSMutableDictionary *) parameters
                                     success:(void (^)(NSMutableArray *)) success
                                     failure:(void (^)(NSError *)) failure;

/**
 Get my actionable view
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getMyActionableViewWithParameters:(NSMutableDictionary *) parameters
                                       success:(void (^)(NSMutableArray *)) success
                                       failure:(void (^)(NSError *)) failure;

/**
 Get my actionable view for application
 @param app: Application
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getMyActionableViewForApplication:(NSString *) app
                                parameters:(NSMutableDictionary *) parameters
                                   success:(void (^)(NSMutableArray *)) success
                                   failure:(void (^)(NSError *)) failure;

/**
 Get my saved view
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getMySavedViewWithParameters:(NSMutableDictionary *) parameters
                                   success:(void (^)(NSMutableArray *)) success
                                   failure:(void (^)(NSError *)) failure;

/**
 Get my saved view for application
 @param app: Application
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getMySavedViewForApplication:(NSString *) app
                                parameters:(NSMutableDictionary *) parameters
                                   success:(void (^)(NSMutableArray *)) success
                                   failure:(void (^)(NSError *)) failure;

/**
 Search activity streams
 @param query: Query for search
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) searchForQuery:(NSString *) query
             parameters:(NSMutableDictionary *) parameters
                success:(void (^)(NSMutableArray *)) success
                failure:(void (^)(NSError *)) failure;

/**
 Search with comma separated tags
 @param tags: tags to be used
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) searchForTags:(NSString *) tags
             parameters:(NSMutableDictionary *) parameters
                success:(void (^)(NSMutableArray *)) success
                failure:(void (^)(NSError *)) failure;

/**
 Search with comma separated query
 @param filterType: filter type
 @param query
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) searchByFilters:(NSString *) filterType
                   query:(NSString *) query
              parameters:(NSMutableDictionary *) parameters
                 success:(void (^)(NSMutableArray *)) success
                 failure:(void (^)(NSError *)) failure;

/**
 Search with search pattern
 @param searchPattern
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) searchWithPattern:(NSString *) searchPattern
            parameters:(NSMutableDictionary *) parameters
               success:(void (^)(NSMutableArray *)) success
               failure:(void (^)(NSError *)) failure;

/**
 Post entry for the given user, group, application and json payload
 @param user: User type. If nil passed @me will be used
 @param group: Group type. If nil passed @all will be used
 @param app: Application type. If nil passed @all will be used
 @param jsonPayload: payload to be post
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) postEntryWithUserType:(AS_USER_TYPE) user
                     groupType:(AS_GROUP_TYPE) group
                       appType:(AS_APPLICATION_TYPE) app
                   jsonPayload:(NSDictionary *) jsonPayload
                    parameters:(NSMutableDictionary *) parameters
                       success:(void (^)(id)) success
                       failure:(void (^)(NSError *)) failure;

/**
 Post entry for the given json payload with default parameters
 @param jsonPayload: payload to be post
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) postEntry:(NSDictionary *) jsonPayload
        parameters:(NSMutableDictionary *) parameters
           success:(void (^)(id)) success
           failure:(void (^)(NSError *)) failure;


/**
 Post microblog entry for the given json payload
 @param user: user type
 @param group: group type
 @param app: app type
 @param jsonPayload: payload to be post
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) postMBEntryUserType:(NSString *) user
                   groupType:(NSString *) group
                     appType:(NSString *) app
                     payload:(NSDictionary *) jsonPayload
                     success:(void (^)(id)) success
                     failure:(void (^)(NSError *)) failure;
@end
