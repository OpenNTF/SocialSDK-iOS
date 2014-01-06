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

#import "SBTAppDelegate.h"

#import "SBTViewController.h"
#import "SBTConnectionsOAuth2EndPoint.h"
#import "SBTConnectionsActivityStreamService.h"
#import "SBTCredentialStore.h"

@implementation SBTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[SBTViewController alloc] initWithNibName:@"IBMViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/**
 This method will be called with the access_code, return this code to the endpoint to retrieve access token
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url)
        return NO;
    
    NSString *urlStr = [url absoluteString];
    NSLog(@"Custom url: %@", urlStr);
    NSArray *splitted = [urlStr componentsSeparatedByString:@"?"];
    NSArray *finalSplitted = [[splitted objectAtIndex:1] componentsSeparatedByString:@"="];
    NSString *oauthCode = [finalSplitted objectAtIndex:1];
    NSLog(@"OAuth code: %@", oauthCode);
    
    NSString *clientId = @"iosOAuthSampleApp";
    NSString *clientSecret = @"56vjIoiFwNFiPiGNCQM9egCpFfkFEjGyFHmDJbLVwqtzaBwasm3ZfimrBSmB";
    NSString *redirectUri = @"ibmoauthsample://test";
    
    SBTConnectionsOAuth2EndPoint *endPoint = (SBTConnectionsOAuth2EndPoint *) [SBTEndPoint findEndPoint:@"connectionsOA2"];
    [endPoint retriveAccessTokenWithClientId:clientId
                                clientSecret:clientSecret
                                 callbackUri:redirectUri
                                   oauthCode:oauthCode
                           completionHandler:^(NSError *error)  {
                               if (error == nil) {
                                   NSLog(@"%@", [SBTCredentialStore loadWithKey:@"IBM_CREDENTIAL_OAUTH2_TOKEN"]);
                                   UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Great!"
                                                                                      message:@"You're now authenticated, you can now explore the APIs. You can see the access token from the log"
                                                                                     delegate:self
                                                                            cancelButtonTitle:nil
                                                                            otherButtonTitles:@"OK", nil];
                                   [alerView show];
                               } else {
                                   NSLog(@"%@", [error description]);
                               }
                           }];
    return YES;
}

@end
