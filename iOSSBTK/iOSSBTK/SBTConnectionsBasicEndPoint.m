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

#import "SBTConnectionsBasicEndPoint.h"
#import "SBTConnectionsClientService.h"
#import "SBTCredentialStore.h"
#import "SBTConstants.h"
#import "SBTConnectionsActivityStreamService.h"
#import "FBLog.h"
#import "SBTHttpClient.h"

@implementation SBTConnectionsBasicEndPoint

- (SBTClientService *) getClientService {
    // Return ConnectionService here
    return [[SBTConnectionsClientService alloc] initWithEndPoint:self];
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
    
    [SBTCredentialStore storeWithKey:IBM_CREDENTIAL_USERNAME value:username];
    [SBTCredentialStore storeWithKey:IBM_CREDENTIAL_PASSWORD value:password];
    
    [self isAuthenticatedWithCompletionHandler:^(NSError *error) {
        if (error == nil) {
            completionHandler(nil);
        } else {
            [SBTCredentialStore removeWithKey:IBM_CREDENTIAL_USERNAME];
            [SBTCredentialStore removeWithKey:IBM_CREDENTIAL_PASSWORD];
            completionHandler(error);
        }
    }];
}

- (void) isAuthenticatedWithCompletionHandler:(void (^)(NSError *)) completionHandler {
    NSString *username = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_USERNAME];
    NSString *password = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_PASSWORD];
    if (username == nil || password == nil) {
        completionHandler([NSError errorWithDomain:@"com.ibm.IBMConnectionsBasicEndPoint"
                                              code:100
                                          userInfo:[NSDictionary dictionaryWithObject:@"Username or password is nil" forKey:@"description"]]);
        return;
    }
    
    SBTConnectionsActivityStreamService *actService = [[SBTConnectionsActivityStreamService alloc] initWithEndPointName:self.endPointName];
    [actService getMyActionableViewWithParameters:nil
                                          success:^(NSMutableArray * list) {
                                              completionHandler(nil);
                                          } failure:^(NSError * error) {
                                              if (IS_DEBUGGING_SBTK)
                                                  [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                                              [SBTCredentialStore removeWithKey:IBM_CREDENTIAL_USERNAME];
                                              [SBTCredentialStore removeWithKey:IBM_CREDENTIAL_PASSWORD];
                                              
                                              completionHandler(error);
                                          }];
}

- (void) logout {
    [SBTCredentialStore removeWithKey:IBM_CREDENTIAL_USERNAME];
    [SBTCredentialStore removeWithKey:IBM_CREDENTIAL_PASSWORD];
    [SBTHttpClient deleteLtpaToken];
}

@end
