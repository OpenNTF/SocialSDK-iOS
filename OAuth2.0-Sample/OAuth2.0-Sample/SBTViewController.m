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

//  This is the controller of the main view. It allows user to authenticate, logout and explore some of the APIs that reuqire authentication

#import "SBTViewController.h"
#import "SBTConnectionsOAuth2EndPoint.h"
#import "SBTCredentialStore.h"
#import "SBTAPIExplorer.h"

@interface SBTViewController ()

@end

@implementation SBTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"OAuth 2.0 Sample App";
    
    NSString *IBM_CREDENTIAL_CONNECTIONS_URL = @"IBM_CREDENTIAL_CONNECTIONS_URL";
    NSString *TEST_BASE_URL = @"https://sbtdev.swg.usma.ibm.com:444";
    [SBTCredentialStore storeWithKey:IBM_CREDENTIAL_CONNECTIONS_URL value:TEST_BASE_URL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 This method initiates the OAuth process by redirecting user to the login form.
 */
- (IBAction)authenticate:(id)sender {
    
    NSString *clientId = @"iosOAuthSampleApp";
    NSString *redirectUri = @"ibmoauthsample://test";
    SBTConnectionsOAuth2EndPoint *endPoint = (SBTConnectionsOAuth2EndPoint *) [SBTEndPoint findEndPoint:@"connectionsOA2"];
    NSURL *urlToOpen = [endPoint formAuthenticationUrlWithClientId:clientId
                                                       callbackUri:redirectUri];
    [[UIApplication sharedApplication] openURL:urlToOpen];
}

/**
 This method logs out user.
 */
- (IBAction)logout:(id)sender {
    SBTConnectionsOAuth2EndPoint *endPoint = (SBTConnectionsOAuth2EndPoint *) [SBTEndPoint findEndPoint:@"connectionsOA2"];
    [endPoint logout];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:@"You logged out!"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

/**
 This methods push API explorer view to the current view
 */
- (IBAction)explore:(id)sender {
    SBTAPIExplorer *apiExplorer = [[SBTAPIExplorer alloc] init];
    apiExplorer.title = @"API Explorer";
    [self.navigationController pushViewController:apiExplorer animated:YES];
}

@end
