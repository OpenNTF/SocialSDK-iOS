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

//  This class is a unit test class for Connections' Activity Stream Service

#import "SBTConnectionsActivityStreamServiceTest.h"
#import "SBTUtilsTest.h"
#import "SBTConstantsTest.h"
#import "SBTConnectionsActivityStreamService.h"

@implementation SBTConnectionsActivityStreamServiceTest


+ (void) setUp {
    [super setUp];
    
    // Set up credentials for authentication
    [SBTUtilsTest setCredentials];
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
 Test to get my status updates
 @pre: none
 @post: id of returned entries should not be nil
 */
- (void) testGetMyStatusUpdates {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsActivityStreamService *actStrService = [[SBTConnectionsActivityStreamService alloc] init];
        [actStrService getMyStatusUpdatesWithParameters:nil success:^(NSMutableArray *list) {
            for (SBTActivityStreamEntry *entry in list) {
                STAssertNotNil(entry.eId, @"ActivityStreamEntry's id is nil");
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
 Test to get all updates
 @pre: none
 @post: id of returned entries should not be nil
 */
- (void) testGetAllUpdates {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsActivityStreamService *actStrService = [[SBTConnectionsActivityStreamService alloc] init];
        [actStrService getAllUpdatesWithParameters:nil success:^(NSMutableArray *list) {
            for (SBTActivityStreamEntry *entry in list) {
                STAssertNotNil(entry.eId, @"ActivityStreamEntry's id is nil");
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
 Test to post entry
 @pre: none
 @post: Returned result should not be nil
 */
- (void) testPostEntry {
    
    /*void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        long time = [[NSDate date] timeIntervalSince1970];
        NSString *objectId = [NSString stringWithFormat:@"%ld", time];
        NSDictionary *actor = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"@me", @"id",
                               nil];
        NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"test update from iOS", @"summary",
                                @"note", @"objectType",
                                objectId, @"id",
                                @"iOS test update", @"displayName",
                                @"http://www.ibm.com", @"url",
                                nil];
        NSDictionary *jsonPayload = [NSDictionary dictionaryWithObjectsAndKeys:
                                     actor, @"actor",
                                     @"POST", @"verb",
                                     [NSString stringWithFormat:@"%ld", time], @"title",
                                     [NSString stringWithFormat:@"Test content-%ld", time], @"content",
                                     object, @"object",
                                     nil];
        IBMConnectionsActivityStreamService *actStrService = [[IBMConnectionsActivityStreamService alloc] init];
        [actStrService postEntry:jsonPayload parameters:nil success:^(id result) {
            STAssertNotNil(result, @"Returned result is nil");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];*/
}

/**
 Test to get my actionable items
 @pre: none
 @post: id of returned entries should not be nil
 */
- (void) testGetActionableItems {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        SBTConnectionsActivityStreamService *actStrService = [[SBTConnectionsActivityStreamService alloc] init];
        [actStrService getMyActionableViewWithParameters:nil success:^(NSMutableArray *list) {
            for (SBTActivityStreamEntry *entry in list) {
                STAssertNotNil(entry.eId, @"Id of the entry is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [SBTUtilsTest executeAsyncBlock:testBlock];
}

- (void) testPostMBEntry {
    
    /*void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsActivityStreamService *actStrService = [[IBMConnectionsActivityStreamService alloc] init];
        NSDictionary *payload = [NSDictionary dictionaryWithObject:@"This is mb entry post" forKey:@"content"];
        [actStrService postMBEntryUserType:nil groupType:nil appType:nil payload:payload success:^(id result) {
            NSLog(@"%@", [result description]);
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];*/
}




@end
