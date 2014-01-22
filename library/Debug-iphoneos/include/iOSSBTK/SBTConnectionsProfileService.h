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

//  This class provides all the service for accessing and updating the Connections' profile

#import "SBTBaseService.h"
#import "SBTConnectionsProfile.h"

@interface SBTConnectionsProfileService : SBTBaseService

#pragma mark - properties


#pragma mark - methods

- (id) init;
- (id) initWithEndPointName:(NSString *)endPointName;

/**
 Get profile information from the Connections
 @param userId: User id of the person. It can be either an email or userId. Method would handle it automatically
 @param success: Success block
 @param failure: Failure block
 */
- (void) getProfile:(NSString *) userId success:(void (^)(SBTConnectionsProfile *)) success failure:(void (^)(NSError *)) failure;

/**
 Update the current profile
 @param profile
 @param success 
 @param failure
 */
- (void) updateProfile:(SBTConnectionsProfile *) profile success:(void (^)(BOOL)) success failure:(void (^)(NSError *)) failure;

/**
 Search profiles
 @param NSDictionary: dictionary of search criteria
 @param success: block to return array of profiles
 @param failure: block to return error
 */
- (void) searchProfilesWithParameters:(NSDictionary *) parameters success:(void (^)(NSMutableArray *listOfProfiles)) success failure:(void (^)(NSError *)) failure;

/**
 Get the report to chain information
 @param userId: user id of the user to search for
 @param parameters: parameters to be fed to the api
 @param success: block to return list of profiles
 @param failure: block to return error
 */
- (void) getReportToChainWithUserId:(NSString *) userId parameters:(NSDictionary *) parameters success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure;

/**
 Get the report to chain information
 @param userId: user id of the user to search for
 @param parameters: parameters to be fed to the api
 @param success: block to return list of profiles
 @param failure: block to return error
 */
- (void) getDirectReportsWithUserId:(NSString *) userId parameters:(NSDictionary *) parameters success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure;


/**
 Get colleagues for the given profile
 @param profile
 @param success: block to return colleagues
 @param failure: block to return error
 */
- (void) getColleaguesWithProfile:(SBTConnectionsProfile *) profile success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure;

/**
 Get colleagues for the given profile
 @param profile
 @param parameters
 @param success: block to return colleagues
 @param failure: block to return error
 */
- (void) getColleaguesWithProfile:(SBTConnectionsProfile *) profile parameters:(NSDictionary *) parameters success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure;

/**
 Upload profile photo
 @param userId: id of the user
 @param data: content of the image
 @param type: ContentType either png or jpeg
 @param success: block to return colleagues
 @param failure: block to return error
 */
- (void) uploadProfilePhotoForUserId:(NSString *) userId data:(NSData *) data contentType:(NSString *) type success:(void (^)(BOOL))success failure:(void (^)(NSError *))failure;

@end
