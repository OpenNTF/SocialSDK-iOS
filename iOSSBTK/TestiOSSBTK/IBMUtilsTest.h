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

#import <Foundation/Foundation.h>

@interface IBMUtilsTest : NSObject

/**
 Call this method to execute async test operations, it will automatically handle semaphores to provide
 concurrency. You can define your testblock as follows:
 void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
    // Your async operation goes here
 }
 @param testBlock
 */
+ (void) executeAsyncBlock:(void (^)(void (^completionBlock)(void))) testBlock;

/**
 Use this method to initialize credentials for unit testing
 */
+ (void) setCredentials;

@end
