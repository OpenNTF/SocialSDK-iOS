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

//  This class is a unit test class for Connections' Profile Service
//  We get the test profile at the beginning of the test

#import "SBTConnectionsProfileServiceTest.h"
#import "SBTConnectionsProfileService.h"
#import "SBTUtilsTest.h"
#import "SBTConstantsTest.h"

@implementation SBTConnectionsProfileServiceTest

SBTConnectionsProfile *testProfile;

+ (void) setUp {
    [super setUp];
    
    // Set up credentials for authentication
    [SBTUtilsTest setCredentials];
    
    // Get information for the test profile
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
        [profileService getProfile:TEST_ACCOUNT_EMAIL success:^(SBTConnectionsProfile *profile) {
            testProfile = profile;
            completionBlock();
        } failure:^(NSError *error) {
            [NSException raise:@"Profile test set up failure!" format:@"Some of the test cases may fail, so fixe this first error: %@", [error description]];
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

+ (void) tearDown {
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
 Test to retrieve test account's profile information
 @pre: none
 @post: profile should not be nil
 */
- (void) testRetrieveProfile {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
        [profileService getProfile:TEST_ACCOUNT_EMAIL success:^(SBTConnectionsProfile *profile) {
            STAssertNotNil(profile, @"profile is nil");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to search for profiles using id of the test account
 @pre: none
 @post: returned profiles's email address should be equal to the test account's
 */
- (void) testSearchProfiles {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    TEST_ACCOUNT_USERID, @"userid",
                                    nil];
        [profileService searchProfilesWithParameters:parameters success:^(NSMutableArray *result) {
            STAssertNotNil(result, @"returned list is nil for search profile");
            if ([result count] == 0)
                STFail(@"returned list is empty, however we searched for the test user account id");
            if ([result count] > 1)
                STFail(@"returned list contains more than one profile, however it should return only one profile");
            SBTConnectionsProfile *profile = [result objectAtIndex:0];
            if (![profile.email isEqualToString:TEST_ACCOUNT_EMAIL])
                STFail(@"Returned result is not same as the test user's email");
            
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to search for profiles using name='Frank'
 @pre: none
 @post: returned profiles' names should include 'Frank'
 */
- (void) testSearchProfilesByName {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Frank", @"name",
                                    nil];
        [profileService searchProfilesWithParameters:parameters success:^(NSMutableArray *result) {
            
            for (SBTConnectionsProfile *profile in result) {
                if ([profile.displayName rangeOfString:@"Frank"].location == NSNotFound)
                    STFail(@"Search result does not match what we searched for");
            }
            
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to update profile
 @pre: none
 @post: request should be successful
 */
- (void) testUpdateProfile {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        // Get the current phone number
        NSString *phoneNumber = testProfile.phoneNumber;
        // Now change it
        NSString *newPhoneNumber = @"";
        if (phoneNumber == nil)
            newPhoneNumber = @"555-123-122";
        else
            newPhoneNumber = [phoneNumber stringByAppendingString:@"77"];
        
        testProfile.phoneNumber = newPhoneNumber;
        
        // Now update it
        SBTConnectionsProfileService *profileService_ = [[SBTConnectionsProfileService alloc] init];
        [profileService_ updateProfile:testProfile success:^(BOOL isSuccessfull) {
            // Now change to the old value for the sake of completeness
            testProfile.phoneNumber = phoneNumber;
            SBTConnectionsProfileService *profileService__ = [[SBTConnectionsProfileService alloc] init];
            [profileService__ updateProfile:testProfile success:^(BOOL success) {
                completionBlock();
            } failure:^(NSError *error) {
                STFail([error description]);
                completionBlock();
            }];
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get colleagues
 @pre: none
 @post: request should end with a success
 */
- (void) testGetColleagues {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
        [profileService getColleaguesWithProfile:testProfile success:^(NSMutableArray *list) {
            completionBlock();
        } failure:^(NSError * error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get colleagues
 @pre: none
 @post: returned list should not be nil
 */
- (void) testGetReportToChain {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
        [profileService getReportToChainWithUserId:TEST_ACCOUNT_USERID parameters:nil success:^(NSMutableArray *list) {
            STAssertNotNil(list, @"report chain list is nil");
            completionBlock();
        } failure:^(NSError * error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get colleagues
 @pre: none
 @post: request should end with a success
 */
- (void) testGetDirectReports {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsProfileService *profileService = [[SBTConnectionsProfileService alloc] init];
        [profileService getDirectReportsWithUserId:TEST_ACCOUNT_USERID parameters:nil success:^(NSMutableArray *list) {
            completionBlock();
        } failure:^(NSError * error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

@end

