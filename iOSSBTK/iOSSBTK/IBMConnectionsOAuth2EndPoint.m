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

#import "IBMConnectionsOAuth2EndPoint.h"
#import "IBMConnectionsClientService.h"
#import "IBMHttpClient.h"
#import "IBMCredentialStore.h"
#import "IBMConstants.h"
#import "IBMConnectionsActivityStreamService.h"
#import "FBLog.h"

@implementation IBMConnectionsOAuth2EndPoint

- (IBMClientService *) getClientService {
    // Return ConnectionService here
    return [[IBMConnectionsClientService alloc] initWithEndPoint:self];
}

- (id) formAuthenticationUrlWithClientId:(NSString *) clientId
                             callbackUri:(NSString *) callbackUri {
    
    if (clientId == nil || callbackUri == nil) {
        return [NSError errorWithDomain:@"com.ibm.IBMOAuth2EndPoint"
                                   code:100
                               userInfo:[NSDictionary dictionaryWithObject:@"clientId or callbackUri cannot be nil" forKey:@"description"]];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@?response_type=code&client_id=%@&callback_uri=%@",
                        [self getURL],
                        IBM_OAUTH_AUTHORIZATION_URL,
                        clientId,
                        callbackUri];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    return url;
}

- (void) retriveAccessTokenWithClientId:(NSString *) clientId
                           clientSecret:(NSString *) clientSecret
                            callbackUri:(NSString *) callbackUri
                              oauthCode:(NSString *) oauthCode
                      completionHandler:(void (^)(NSError *)) completionHandler {
    
    if (clientId == nil || clientSecret == nil || callbackUri == nil || oauthCode == nil) {
        completionHandler([NSError errorWithDomain:@"com.ibm.IBMOAuth2EndPoint"
                                              code:100
                                          userInfo:[NSDictionary dictionaryWithObject:@"clientId, clientSecret, callbackUri or oauthCode cannot be nil" forKey:@"description"]]);
        return;
    }
    
    NSString *body = [NSString stringWithFormat:
                      @"grant_type=authorization_code&code=%@&callbacl_uri=%@&client_id=%@&client_secret=%@",
                      oauthCode,
                      callbackUri,
                      clientId,
                      clientSecret];
    
    IBMHttpClient *httpClient = [[IBMHttpClient alloc] initWithBaseURL:[NSURL URLWithString:[IBMUtils getUrlForEndPoint:self.endPointName]]];
    [httpClient postPath:IBM_OAUTH_TOKEN_URL
              parameters:[NSDictionary dictionaryWithObject:body forKey:@"body"]
                 success:^(AFHTTPRequestOperation *request, id response) {
                     NSError *error;
                     id processedResult = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
                     
                     if (error != nil) {
                         completionHandler([NSError errorWithDomain:@"com.ibm.IBMOAuth2EndPoint"
                                                               code:100
                                                           userInfo:[NSDictionary dictionaryWithObject:@"Error while processing Json response" forKey:@"description"]]);
                     } else {
                         NSString *accessToken = [processedResult objectForKey:@"access_token"];
                         NSString *expiresIn = [processedResult objectForKey:@"expires_in"];
                         NSString *refreshToken = [processedResult objectForKey:@"refresh_token"];
                         
                         [IBMCredentialStore storeWithKey:IBM_CREDENTIAL_OAUTH2_TOKEN value:accessToken];
                         [IBMCredentialStore storeWithKey:IBM_CREDENTIAL_OAUTH2_REFRESH_TOKEN value:refreshToken];
                         [IBMCredentialStore storeWithKey:IBM_CREDENTIAL_OAUTH2_EXPIRES_IN value:expiresIn];
                         completionHandler(nil);
                     }
                 } failure:^(AFHTTPRequestOperation *request, NSError *error) {
                     completionHandler(error);
                 }];
}

- (void) isAuthenticatedWithCompletionHandler:(void (^)(NSError *)) completionHandler {
    
    NSString *accessToken = [IBMCredentialStore loadWithKey:IBM_CREDENTIAL_OAUTH2_TOKEN];
    if (accessToken == nil) {
        [NSException raise:@"Authentication Problem" format:@"Access Token is not provided (IBMClientService)"];
    }
    
    IBMConnectionsActivityStreamService *actService = [[IBMConnectionsActivityStreamService alloc] initWithEndPointName:self.endPointName];
    [actService getMyActionableViewWithParameters:nil
                                          success:^(NSMutableArray * list) {
                                              completionHandler(nil);
                                          } failure:^(NSError * error) {
                                              if (IS_DEBUGGING_SBTK)
                                                  [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                                              completionHandler(error);
                                          }];
}

- (void) logout {
    [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_OAUTH2_TOKEN];
    [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_OAUTH2_REFRESH_TOKEN];
    [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_OAUTH2_EXPIRES_IN];
}

@end
