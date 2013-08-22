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

//  This class is a unit test class for Connections' Community Service
//  This class creates a test community at the beginning of the test and
//  delete it after all the test cases completed

#import "IBMConnectionsCommunityServiceTest.h"
#import "IBMUtilsTest.h"
#import "IBMConstantsTest.h"
#import "IBMConnectionsCommunityService.h"

@implementation IBMConnectionsCommunityServiceTest

IBMConnectionsCommunity *testCommunity;

+ (void) setUp {
    [super setUp];
    
    // Set up credentials for authentication
    [IBMUtilsTest setCredentials];
    
    // Create a test community
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        IBMConnectionsCommunity *comm = [[IBMConnectionsCommunity alloc] init];
        long time = [[NSDate date] timeIntervalSince1970];
        comm.title = [NSString stringWithFormat:@"%@-%ld", @"Unit test community by iOS", time];
        comm.content = [NSString stringWithFormat:@"%@-%ld", @"Content of the test community...", time];
        comm.communityType = @"public";
        
        [comService createCommunity:comm success:^(IBMConnectionsCommunity *commmunity) {
            testCommunity = commmunity;
            completionBlock();
        } failure:^(NSError *error) {
            [NSException raise:@"Test community creation failed!" format:@"Test community was not created succcessfully, other test methods likely to fail"];
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

+ (void) tearDown {
    
    // Delete a test community
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        [comService deleteCommunity:testCommunity success:^(BOOL success) {
            completionBlock();
        } failure:^(NSError *error) {
            [NSException raise:@"Test community deletion failed!" format:@"Test community was not deleted, you may need to manually delete the community."];
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
    
    [super tearDown];
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

/**
 Test to get community
 @pre: none
 @post: returned community's title and content should be equal to the created one
 */
- (void) testGetCommunity {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        [comService getCommunityWithUuid:testCommunity.communityUuid success:^(IBMConnectionsCommunity *community) {
            STAssertNotNil(community, @"Community is nil");
            STAssertNotNil(community.communityUuid, @"Community uuid nil");
            STAssertNotNil(community.communityUrl, @"Community url nil");
            STAssertEqualObjects(testCommunity.title, community.title, @"Title's are not same!");
            STAssertEqualObjects(testCommunity.content, community.content, @"Content's are not same!");
            completionBlock();
        } failure:^(NSError *error) {
            completionBlock();
            STFail([error description]);
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to update community
 @pre: getCommunity request result with success
 @post: request should end with success (HTTP 200)
 */
- (void) testUpdateCommunity {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        testCommunity.content = @"Content of the test community after the update...";
        [comService updateCommunity:testCommunity success:^(BOOL success) {
            completionBlock();
        } failure:^(NSError *error) {
            completionBlock();
            STFail([error description]);
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get my communities
 @pre: none
 @post: returned communnities' uuid and url should not be nil
 */
- (void) testGetMyCommunities {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        [comService getMyCommunitiesWithSuccess:^(NSMutableArray *list) {
            for (IBMConnectionsCommunity *c in list) {
                STAssertNotNil(c.communityUuid, @"Community id is nil");
                STAssertNotNil(c.communityUrl, @"Community url is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            completionBlock();
            STFail([error description]);
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get public communities
 @pre: none
 @post: returned communnities' uuid and url should not be nil
 */
- (void) testGetPublicCommunities {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        [comService getPublicCommunitiesWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMConnectionsCommunity *c in list) {
                STAssertNotNil(c.communityUuid, @"Community id is nil");
                STAssertNotNil(c.communityUrl, @"Community url is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            completionBlock();
            STFail([error description]);
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to create a community
 @pre: none
 @post: request should end with success (Http 200)
 */
- (void) testCreateAndDeleteCommunity {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        IBMConnectionsCommunity *comm = [[IBMConnectionsCommunity alloc] init];
        long time = [[NSDate date] timeIntervalSince1970];
        comm.title = [NSString stringWithFormat:@"%@-%ld", @"Test community by iOS", time];
        comm.content = [NSString stringWithFormat:@"%@-%ld", @"Content of the test community...", time];
        comm.communityType = @"public";
        
        [comService createCommunity:comm success:^(IBMConnectionsCommunity *commmunity) {
            STAssertNotNil(commmunity.communityUuid, @"Community id is nil");
            STAssertNotNil(commmunity.communityUrl, @"Community url is nil");
            IBMConnectionsCommunityService *comService_ = [[IBMConnectionsCommunityService alloc] init];
            [comService_ deleteCommunity:commmunity success:^(BOOL success) {
                completionBlock();
            } failure:^(NSError *error) {
                completionBlock();
                STFail([error description]);
            }];
        } failure:^(NSError *error) {
            completionBlock();
            STFail([error description]);
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to create, get and delete a subcommunity
 @pre: none
 @post: request should end with success (Http 200)
 */
- (void) testCreateGetAndDeleteSubCommunity {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService_ = [[IBMConnectionsCommunityService alloc] init];
        IBMConnectionsCommunity *subComm = [[IBMConnectionsCommunity alloc] init];
        long time = [[NSDate date] timeIntervalSince1970];
        subComm.title = [NSString stringWithFormat:@"%@-%ld", @"Test sub-community by iOS", time];
        subComm.content = [NSString stringWithFormat:@"%@-%ld", @"Content of the test subcommunity...", time];
        subComm.communityType = @"public";
        [comService_ createSubCommunity:subComm forCommunity:testCommunity success:^(IBMConnectionsCommunity *subCommunity) {
            STAssertNotNil(subCommunity.communityUuid, @"Community id is nil");
            STAssertNotNil(subCommunity.communityUrl, @"Community url is nil");
            
            // Now get this subcommunity
            IBMConnectionsCommunityService *comService__ = [[IBMConnectionsCommunityService alloc] init];
            [comService__ getSubCommunitiesForCommunity:testCommunity parameters:nil success:^(NSMutableArray *list) {
                STAssertNotNil(list, @"List is nil");
                bool contains = NO;
                for (IBMConnectionsCommunity *comm in list) {
                    if ([comm.communityUuid rangeOfString:subCommunity.communityUuid].location != NSNotFound) {
                        contains = YES;
                        break;
                    }
                }
                
                if (contains == NO)
                    STFail(@"Newly created subcommunity is not returned");
                
                // Now delete this subcommunity
                IBMConnectionsCommunityService *comService__ = [[IBMConnectionsCommunityService alloc] init];
                [comService__ deleteCommunity:subCommunity success:^(BOOL success) {
                    completionBlock();
                } failure:^(NSError *error) {
                    completionBlock();
                    STFail([error description]);
                }];
            } failure:^(NSError *error) {
                completionBlock();
                STFail([error description]);
            }];
        } failure:^(NSError *error) {
            completionBlock();
            STFail([error description]);
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Get members of a community
 @pre: none
 @post: returned list should not be nil
 */
- (void) testGetMembersOfCommunity {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        [comService getMembersForCommunity:testCommunity success:^(NSMutableArray *list) {
            STAssertNotNil(list, @"list is nil, it should at least contains me");
            completionBlock();
        } failure:^(NSError *error) {
            completionBlock();
            STFail([error description]);
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Get bookmarks of a community
 @pre: none
 @post: none for now
 */
- (void) testGetBookmarksOfCommunity {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        [comService getBookmarksForCommunity:testCommunity success:^(NSMutableArray *list) {
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Get forum topics of a community
 @pre: none
 @post: none for now
 */
- (void) testGetForumTopicsOfCommunity {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsCommunityService *comService = [[IBMConnectionsCommunityService alloc] init];
        [comService getForumTopicsForCommunity:testCommunity success:^(NSMutableArray *list) {
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}


@end
