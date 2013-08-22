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

#import "IBMBasicEndPoint.h"

@interface IBMConnectionsBasicEndPoint : IBMBasicEndPoint

- (IBMClientService *) getClientService;

/**
 This method allows user to authenticate to the endpoint using basic oauth
 @param username
 @param password
 @param completionHandler: upon completion this handler will be called with an error object. If it is nil, then the authentication is successful
 */
- (void) authenticateWithUsername:(NSString *) username
                         password:(NSString *) password
                completionHandler:(void (^)(NSError *)) completionHandler;

/**
 This method checks if users is authenticated to the endPoint.
 Current mechanism is to try to get the user's actionable view using activity stream api.
 @param completionHandler: upon completion result is returned with an error object. If nil, user is authenticated
 */
- (void) isAuthenticatedWithCompletionHandler:(void (^)(NSError *)) completionHandler;

/**
 Logout
 */
- (void) logout;

@end
