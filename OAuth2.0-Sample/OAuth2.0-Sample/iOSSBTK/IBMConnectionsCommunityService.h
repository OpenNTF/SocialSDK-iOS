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

#import "IBMBaseService.h"
#import "IBMConnectionsCommunity.h"
#import "IBMCommunityMember.h"
#import "IBMCommunityBookmark.h"
#import "IBMCommunityForumTopic.h"

@interface IBMConnectionsCommunityService : IBMBaseService

#pragma mark - properties


#pragma mark - methods

- (id) init;
- (id) initWithEndPointName:(NSString *)endPointName;

/**
 Get community object with community uuid
 @param uuid: Community uuid
 @param succes: block to return success result
 @para failure: block to return error
 */
- (void) getCommunityWithUuid:(NSString *) uuid
                      success:(void (^)(IBMConnectionsCommunity *)) success
                      failure:(void (^)(NSError *)) failure;

/**
 Create the given community object
 @param community: community to be created
 @param succes: block to return newly created community
 @para failure: block to return error
 */
- (void) createCommunity:(IBMConnectionsCommunity *) community
                 success:(void (^)(IBMConnectionsCommunity *)) success
                 failure:(void (^)(NSError *)) failure;
/**
 Update the given community object
 @param community: community to be updated
 @param succes: block to return success result
 @para failure: block to return error
 */
- (void) updateCommunity:(IBMConnectionsCommunity *) community
                 success:(void (^)(BOOL)) success
                 failure:(void (^)(NSError *)) failure;

/**
 Delete the given community object
 @param community: community to be deleted
 @param succes: block to return success result
 @para failure: block to return error
 */
- (void) deleteCommunity:(IBMConnectionsCommunity *) community
                 success:(void (^)(BOOL)) success
                 failure:(void (^)(NSError *)) failure;

/**
 Get all of my communities
 @param succes: block to return list of community objects
 @para failure: block to return error
 */
- (void) getMyCommunitiesWithSuccess:(void (^)(NSMutableArray *)) success
                             failure:(void (^)(NSError *)) failure;

/**
 Get public communities
 @param params: parameters for the query
 @param succes: block to return list of community objects
 @para failure: block to return error
 */
- (void) getPublicCommunitiesWithParameters:(NSDictionary *) params
                                    success:(void (^)(NSMutableArray *)) success
                                    failure:(void (^)(NSError *)) failure;

/**
 Create the given subcommunity object
 @param subCommunity: community to be created
 @param community: parent community
 @param succes: block to return newly created community
 @para failure: block to return error
 */
- (void) createSubCommunity:(IBMConnectionsCommunity *) subCommunity
               forCommunity:(IBMConnectionsCommunity *) community
                    success:(void (^)(IBMConnectionsCommunity *)) success
                    failure:(void (^)(NSError *)) failure;

/**
 Get the sub sommunities of a given community
 @param community: community whose subcommunities are retrieved
 @param params: parameter to be used for the request
 @param succes: block to return newly created community
 @para failure: block to return error
 */
- (void) getSubCommunitiesForCommunity:(IBMConnectionsCommunity *) community
                            parameters:(NSDictionary *) params
                               success:(void (^)(NSMutableArray *)) success
                               failure:(void (^)(NSError *)) failure;

/**
 Get the members of a given community
 @param community: community whose members are retrieved
 @param succes: block to return member list
 @para failure: block to return error
 */
- (void) getMembersForCommunity:(IBMConnectionsCommunity *) community
                        success:(void (^)(NSMutableArray *)) success
                        failure:(void (^)(NSError *)) failure;

/**
 Add the given members to a given community
 @param member: Member to add
 @param community: community to be targeted
 @param succes: block to return success result
 @para failure: block to return error
 */
- (void) addMember:(IBMCommunityMember *) member
     fromCommunity:(IBMConnectionsCommunity *) community
           success:(void (^)(BOOL)) success
           failure:(void (^)(NSError *)) failure;

/**
 Delete the given members from a given community
 @param member: Member to remove
 @param community: community to be targeted
 @param succes: block to return success result
 @para failure: block to return error
 */
- (void) deleteMember:(IBMCommunityMember *) member
        fromCommunity:(IBMConnectionsCommunity *) community
              success:(void (^)(BOOL)) success
              failure:(void (^)(NSError *)) failure;


/**
 Get bookmarks of a given community
 @param community: community whose bookmarks are retrieved
 @param succes: block to return newly created community
 @para failure: block to return error
 */
- (void) getBookmarksForCommunity:(IBMConnectionsCommunity *) community
                          success:(void (^)(NSMutableArray *)) success
                          failure:(void (^)(NSError *)) failure;

/**
 Get forum topics of a given community
 @param community: community whose forum topics are retrieved
 @param succes: block to return newly created community
 @para failure: block to return error
 */
- (void) getForumTopicsForCommunity:(IBMConnectionsCommunity *) community
                            success:(void (^)(NSMutableArray *)) success
                            failure:(void (^)(NSError *)) failure;

@end
