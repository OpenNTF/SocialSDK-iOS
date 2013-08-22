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

#import "IBMOAuth2EndPoint.h"

@interface IBMConnectionsOAuth2EndPoint : IBMOAuth2EndPoint

- (IBMClientService *) getClientService;

/**
 This method creates and returns the url to the develper. Developer can then use this url to open Safari
 @param clientId
 @param callbackUri
 */
- (id) formAuthenticationUrlWithClientId:(NSString *) clientId
                             callbackUri:(NSString *) callbackUri;

/**
 Once user is returned back to the application developer needs to call this method with retrieved oauth code to complete the process. This is the last step for the developer.
 @param clientId
 @param clientSecret
 @param callbackUri
 @param oauthCode
 */
- (void) retriveAccessTokenWithClientId:(NSString *) clientId
                           clientSecret:(NSString *) clientSecret
                            callbackUri:(NSString *) callbackUri
                              oauthCode:(NSString *) oauthCode
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
