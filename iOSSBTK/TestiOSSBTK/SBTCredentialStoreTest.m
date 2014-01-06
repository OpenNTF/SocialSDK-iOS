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

//  This class is a unit test class for CredentialStore

#import "SBTCredentialStoreTest.h"
#import "SBTCredentialStore.h"

@implementation SBTCredentialStoreTest

NSString *testCaseKey;
NSString *testCaseValue;

+ (void)setUp
{
    [super setUp];
    
    testCaseKey = [NSString stringWithFormat:@"TEST_CASE_KEY_%f", [[NSDate date] timeIntervalSince1970]];
    testCaseValue = @"TEST_CASE_VALUE";
}

+ (void)tearDown
{
    [super tearDown];
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void) testStoreGetAndRemove {
    
    // First create
    BOOL result = [SBTCredentialStore storeWithKey:testCaseKey value:testCaseValue];
    if (result == NO) {
        STFail(@"Unable to store key value pair");
    }
    
    // Second retrieve
    NSString *value = [SBTCredentialStore loadWithKey:testCaseKey];
    STAssertNotNil(value, @"We've saved a key value pair but could not get it correctly");
    STAssertEqualObjects(value, testCaseValue, @"Returned value is not the one we stored");
    
    // Third delete
    result = [SBTCredentialStore removeWithKey:testCaseKey];
    if (result == NO) {
        STFail(@"Unable to remove key value pair");
    }
}

@end
