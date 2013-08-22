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

//  Utility class for testing

#import "IBMUtilsTest.h"
#import "IBMCredentialStore.h"
#import "IBMConstants.h"
#import "IBMConstantsTest.h"

@implementation IBMUtilsTest

+ (void) executeAsyncBlock:(void (^)(void (^completionBlock)(void))) testBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void (^completionBlock)(void) = ^ {
        dispatch_semaphore_signal(semaphore);
    };
    testBlock(completionBlock);
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    }
}

+ (void) setCredentials {
    [IBMCredentialStore storeWithKey:IBM_CREDENTIAL_CONNECTIONS_URL value:TEST_BASE_URL];
    [IBMCredentialStore storeWithKey:@"IBM_CREDENTIAL_ACME_URL" value:TEST_ACME_BASE_URL];
    [IBMCredentialStore storeWithKey:IBM_CREDENTIAL_USERNAME value:TEST_ACCOUNT_EMAIL];
    [IBMCredentialStore storeWithKey:IBM_CREDENTIAL_PASSWORD value:TEST_ACCOUNT_PASSWORD];
}

@end
