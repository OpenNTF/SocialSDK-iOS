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

//  This is a controller for the API explorer.

#import "SBTAPIExplorer.h"
#import <iOSSBTK/SBTConnectionsProfileService.h>
#import <iOSSBTK/SBTConnectionsActivityStreamService.h>
#import <iOSSBTK/SBTConnectionsCommunityService.h>
#import <iOSSBTK/SBTCredentialStore.h>
#import <iOSSBTK/SBTConnectionsFileService.h>
#import <iOSSBTK/SBTConnectionsOAuth2EndPoint.h>

@interface SBTAPIExplorer ()

@property (nonatomic, strong) NSMutableArray *apisToExplore;


@property (nonatomic, strong) NSNumber *isAuthenticated;

@end

@implementation SBTAPIExplorer

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isAuthenticated = [NSNumber numberWithBool:NO];
    
    // Fill out the API titles here and initiate requestst when a cell is selected
    self.apisToExplore = [[NSMutableArray alloc] initWithObjects:
                          NSLocalizedStringWithDefaultValue(@"APITitleGetMyCommunities",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Get My Communities",
                                  @"API Title Get My Communities"),
                          NSLocalizedStringWithDefaultValue(@"APITitleGetMyStatusUpdates",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Get My Status Updates",
                                  @"API Title Get My Status Updates"),
                          NSLocalizedStringWithDefaultValue(@"APITitlePostAnActivityStreamEntry",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Post an Activity Stream Entry",
                                  @"API Title Post an Activity Stream Entry"),
                          NSLocalizedStringWithDefaultValue(@"APITitlePostAMicroblogEntry",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Post a Microblog Entry",
                                  @"API Title Post a Microblog Entry"),
                          NSLocalizedStringWithDefaultValue(@"APITitleUploadAFile",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Upload a file",
                                  @"API Title Upload a file"),
                          nil];
    
    // Lets check if user is authenticated
    [self performSelector:@selector(checkAuthentication) withObject:nil afterDelay:0.3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.apisToExplore count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.apisToExplore objectAtIndex:indexPath.section];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *APISuccess = NSLocalizedStringWithDefaultValue(@"APISuccessMessage",
                                                             nil,
                                                             [NSBundle mainBundle],
                                                             @"Success! You can see the output at the console",
                                                             @"Message shown on API run success");
    
    NSString *APIFailure = NSLocalizedStringWithDefaultValue(@"APIFailureMessage",
                                                             nil,
                                                             [NSBundle mainBundle],
                                                             @"Failure! Check the console for an explanation",
                                                             @"Message shown on API run failure");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.isAuthenticated boolValue] == NO)
        return;
    
    if (indexPath.section == 0) {
        // Get My Communities
        
        SBTConnectionsCommunityService *commSrvc = [[SBTConnectionsCommunityService alloc] initWithEndPointName:@"connectionsOA2"];
        [commSrvc getMyCommunitiesWithSuccess:^(NSMutableArray *listOfCommunities) {
            for (SBTConnectionsCommunity *comm in listOfCommunities) {
                NSLog(@"%@", [comm description]);
            }
            [self reportWithAlert:APISuccess];
        } failure:^(NSError *error) {
            NSLog(@"%@", [error description]);
            [self reportWithAlert:APIFailure];
        }];
    } else if (indexPath.section == 1) {
        // Get my status updates from activity stream
        SBTConnectionsActivityStreamService *actService = [[SBTConnectionsActivityStreamService alloc] initWithEndPointName:@"connectionsOA2"];
        [actService getMyActionableViewWithParameters:nil
                                              success:^(NSMutableArray * list) {
                                                  for (SBTActivityStreamEntry *entry in list) {
                                                      NSLog(@"%@", [entry description]);
                                                  }
                                                  [self reportWithAlert:APISuccess];
                                              } failure:^(NSError * error) {
                                                  NSLog(@"%@", [error description]);
                                                  [self reportWithAlert:APIFailure];
                                              }];
    } else if (indexPath.section == 2) {
        // Post an Activity Stream Entry
        SBTConnectionsActivityStreamService *actService = [[SBTConnectionsActivityStreamService alloc] initWithEndPointName:@"connectionsOA2"];
        
        long time = [[NSDate date] timeIntervalSince1970];
        NSString *objectId = [NSString stringWithFormat:@"%ld", time];
        NSDictionary *actor = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"@me", @"id",
                               nil];
        
        NSString *ASUpdateSummary = NSLocalizedStringWithDefaultValue(@"ASUpdateSummary",
                                                                    nil,
                                                                    [NSBundle mainBundle],
                                                                    @"Test update from iOS",
                                                                    @"Test Activity Stream update summary");
        
        NSString *ASUpdateDisplayName = NSLocalizedStringWithDefaultValue(@"ASUpdateDisplayName",
                                                                    nil,
                                                                    [NSBundle mainBundle],
                                                                    @"iOS test update",
                                                                    @"Test Activity Stream update displayName");
        NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:
                                ASUpdateSummary, @"summary",
                                @"note", @"objectType",
                                objectId, @"id",
                                ASUpdateDisplayName, @"displayName",
                                @"http://www.ibm.com", @"url",
                                nil];
        NSDictionary *jsonPayload = [NSDictionary dictionaryWithObjectsAndKeys:
                                     actor, @"actor",
                                     @"POST", @"verb",
                                     [NSString stringWithFormat:@"%ld", time], @"title",
                                     [NSString stringWithFormat:@"Test content-%ld", time], @"content",
                                     object, @"object",
                                     nil];
        
        [actService postEntry:jsonPayload
                   parameters:nil
                      success:^(id result) {
                          NSLog(@"%@", [result description]);
                          [self reportWithAlert:APISuccess];
                      }failure:^(NSError *error) {
                          NSLog(@"%@", [error description]);
                          [self reportWithAlert:APIFailure];
                      }];
    } else if (indexPath.section == 3) {
        NSString *testEntryPost = NSLocalizedStringWithDefaultValue(@"MicroblogTestEntryPost",
                                                                    nil,
                                                                    [NSBundle mainBundle],
                                                                    @"This is mb entry post",
                                                                    @"Microblog test entry post");
        // Post a Microblog entry
        SBTConnectionsActivityStreamService *actService = [[SBTConnectionsActivityStreamService alloc] initWithEndPointName:@"connectionsOA2"];
        NSDictionary *payload = [NSDictionary dictionaryWithObject:testEntryPost forKey:@"content"];
        [actService postMBEntryUserType:nil
                              groupType:nil
                                appType:nil
                                payload:payload
                                success:^(id result) {
                                    NSLog(@"%@", [result description]);
                                    [self reportWithAlert:APISuccess];
                                } failure:^(NSError *error) {
                                    NSLog(@"%@", [error description]);
                                    [self reportWithAlert:APIFailure];
                                }];
        
    } else if (indexPath.section == 4) {
        // Upload a file
        NSString *content = NSLocalizedStringWithDefaultValue(@"TestFileContent",
                                                             nil,
                                                             [NSBundle mainBundle],
                                                             @"This is the test content of the file",
                                                             @"Content of the Test File");
        long time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"OAuthFile_%ld", time];
        SBTConnectionsFileService *fS = [[SBTConnectionsFileService alloc] initWithEndPointName:@"connectionsOA2"];
        [fS uploadFileWithContent:content
                         fileName:fileName
                         mimeType:@"text/plain"
                          success:^(SBTFileEntry *file) {
                              NSLog(@"%@", [file description]);
                              [self reportWithAlert:APISuccess];
                          } failure:^(NSError *error) {
                              NSLog(@"%@", [error description]);
                              [self reportWithAlert:APIFailure];
                          }];
    }
}


/**
 Check if user is authenticated
 */
- (void) checkAuthentication {
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        @try {
            SBTConnectionsOAuth2EndPoint *endPoint = (SBTConnectionsOAuth2EndPoint *) [SBTEndPoint findEndPoint:@"connectionsOA2"];
            [endPoint isAuthenticatedWithCompletionHandler:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"%@", [error description]);
                    [self reportWithAlert:NSLocalizedStringWithDefaultValue(@"AuthProblemMessage",
                                                             nil,
                                                             [NSBundle mainBundle],
                                                             @"Failure! Authentication problem!",
                                                             @"Message shown when there is a problem with authentication")];
                } else {
                    self.isAuthenticated = [NSNumber numberWithBool:YES];
                }
                completionBlock();
            }];
        } @catch (NSException *exception) {
            NSLog(@"%@", [exception description]);
            [self reportWithAlert:NSLocalizedStringWithDefaultValue(@"NotAuthenticatedErrorMessage",
                                                             nil,
                                                             [NSBundle mainBundle],
                                                             @"Failure! You need to authenticate first!",
                                                             @"Message shown when the user is not authenticated")];
            completionBlock();
        }
    };
    
    [self executeAsyncBlock:testBlock];
}

- (void) reportWithAlert:(NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"ResultAlertTitle",
                                                             nil,
                                                             [NSBundle mainBundle],
                                                             @"Result",
                                                             @"Title for Result Alert")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedStringWithDefaultValue(@"ResultAlertButton",
                                                             nil,
                                                             [NSBundle mainBundle],
                                                             @"OK",
                                                             @"Button for Result Alert"), nil];
    [alertView show];
}

- (void) executeAsyncBlock:(void (^)(void (^completionBlock)(void))) testBlock {
    
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

@end
