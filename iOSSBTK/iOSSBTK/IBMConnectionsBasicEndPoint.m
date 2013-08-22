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

#import "IBMConnectionsBasicEndPoint.h"
#import "IBMConnectionsClientService.h"
#import "IBMCredentialStore.h"
#import "IBMConstants.h"
#import "IBMConnectionsActivityStreamService.h"
#import "FBLog.h"
#import "IBMHttpClient.h"

@implementation IBMConnectionsBasicEndPoint

- (IBMClientService *) getClientService {
    // Return ConnectionService here
    return [[IBMConnectionsClientService alloc] initWithEndPoint:self];
}

- (void) authenticateWithUsername:(NSString *) username
                         password:(NSString *) password
                completionHandler:(void (^)(NSError *)) completionHandler {
    
    if (username == nil || password == nil) {
        completionHandler([NSError errorWithDomain:@"com.ibm.IBMBasicEndPoint"
                                              code:100
                                          userInfo:[NSDictionary dictionaryWithObject:@"username or password cannot be nil" forKey:@"description"]]);
        return;
    }
    
    [IBMCredentialStore storeWithKey:IBM_CREDENTIAL_USERNAME value:username];
    [IBMCredentialStore storeWithKey:IBM_CREDENTIAL_PASSWORD value:password];
    
    [self isAuthenticatedWithCompletionHandler:^(NSError *error) {
        if (error == nil) {
            completionHandler(nil);
        } else {
            [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_USERNAME];
            [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_PASSWORD];
            completionHandler(error);
        }
    }];
}

- (void) isAuthenticatedWithCompletionHandler:(void (^)(NSError *)) completionHandler {
    NSString *username = [IBMCredentialStore loadWithKey:IBM_CREDENTIAL_USERNAME];
    NSString *password = [IBMCredentialStore loadWithKey:IBM_CREDENTIAL_PASSWORD];
    if (username == nil || password == nil) {
        completionHandler([NSError errorWithDomain:@"com.ibm.IBMConnectionsBasicEndPoint"
                                              code:100
                                          userInfo:[NSDictionary dictionaryWithObject:@"Username or password is nil" forKey:@"description"]]);
        return;
    }
    
    IBMConnectionsActivityStreamService *actService = [[IBMConnectionsActivityStreamService alloc] initWithEndPointName:self.endPointName];
    [actService getMyActionableViewWithParameters:nil
                                          success:^(NSMutableArray * list) {
                                              completionHandler(nil);
                                          } failure:^(NSError * error) {
                                              if (IS_DEBUGGING_SBTK)
                                                  [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                                              [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_USERNAME];
                                              [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_PASSWORD];
                                              
                                              completionHandler(error);
                                          }];
}

- (void) logout {
    [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_USERNAME];
    [IBMCredentialStore removeWithKey:IBM_CREDENTIAL_PASSWORD];
    [IBMHttpClient deleteLtpaToken];
}

@end
