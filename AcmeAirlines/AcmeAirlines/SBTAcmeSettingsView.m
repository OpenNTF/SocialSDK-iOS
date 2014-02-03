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

//  This class is a way to set up things for the purpose of demo.

#import "SBTAcmeSettingsView.h"
#import "SBTAcmeConstant.h"
#import "SBTAcmeUtils.h"
#import <iOSSBTK/SBTCredentialStore.h>
#import "SBTAcmeFlight.h"
#import <iOSSBTK/SBTConnectionsCommunityService.h>
#import <iOSSBTK/SBTConnectionsFileService.h>
#import <iOSSBTK/FBLog.h>

@interface SBTAcmeSettingsView ()

@end

@implementation SBTAcmeSettingsView

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

    self.title = NSLocalizedStringWithDefaultValue(@"SETTINGS",
                                  @"Common",
                                  [NSBundle mainBundle],
                                  @"Settings",
                                  @"Settings common label");
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:90.0/255
                                                                        green:91.0/255
                                                                         blue:71.0/255
                                                                        alpha:1];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"CANCEL",
                                  @"Common",
                                  [NSBundle mainBundle],
                                  @"Cancel",
                                  @"Cancel common label")
                        style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelItem;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 2;
    else if (section == 1)
        return 1;
    else
        return 1;
}

- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section
{
    if (section == 0 || section == 1) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            return 50;
        else
            return 40;
    }
    else
        return 10;
}


- (UIView *) tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        // Title label
        
        CGRect viewFrame;
        float textSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textSize = TEXT_SIZE_IPAD;
            viewFrame = CGRectMake(0, 0, WIDTH_FOR_IPAD-2*MARGIN_FOR_IPAD_GROUPED_TABLEVIEW, 50);
        } else {
            textSize = TEXT_SIZE_SMALL - 1;
            viewFrame = CGRectMake(0, 0, WIDTH_FOR_IPHONE-2*MARGIN_FOR_IPHONE_GROUPED_TABLEVIEW, 40);
        }
        
        UIView *view = [[UIView alloc] initWithFrame:viewFrame];
        
        CGRect labelFrame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            labelFrame = CGRectMake(MARGIN_FOR_IPAD_GROUPED_TABLEVIEW, 10, 400, 40);
        } else {
            labelFrame = CGRectMake(MARGIN_FOR_IPHONE_GROUPED_TABLEVIEW, 10, 280, 30);
        }
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.font = [UIFont fontWithName:TEXT_FONT size:textSize];
        label.textColor = [UIColor colorWithRed:245.0/255
                                          green:245.0/255
                                           blue:245.0/255
                                          alpha:1];
        label.textAlignment = NSTextAlignmentLeft;
        label.adjustsFontSizeToFitWidth = YES;
        label.numberOfLines = 0;
        if (section == 0)
            
            label.text = NSLocalizedStringWithDefaultValue(@"CREATE_REMOVE_TEST_COMMUNITY",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Here you can create/remove test community",
                                  @"Create or remove test community");
        else if (section == 1)
            
            label.text = NSLocalizedStringWithDefaultValue(@"UPLOAD_LOG_FILE_TO_CONNECTIONS",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Here you can upload log file to Connections",
                                  @"Upload log file to Connections");
        
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        
        return view;
    } else {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        return view;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        float textSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textSize = TEXT_SIZE_IPAD;
        } else {
            textSize = TEXT_SIZE_SMALL;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:textSize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
            cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"CREATE_TEST_FLIGHT_101_COMMUNITY",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Create Test Community for Flight 101",
                                  @"Create Test Community for Flight 101");
        else if (indexPath.row == 1)
            cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"REMOVE_TEST_FLIGHT_101_COMMUNITY",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Remove Test Community for Flight 101",
                                  @"Remove Test Community for Flight 101");
    } else if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"UPLOAD_LOG",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Upload log file",
                                  @"Upload log file");
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSString *okLabel = NSLocalizedStringWithDefaultValue(@"OK",
                                  @"Common",
                                  [NSBundle mainBundle],
                                  @"OK",
                                  @"OK Common label");
    
        NSString *errorLabel = NSLocalizedStringWithDefaultValue(@"ERROR",
                                  @"Common",
                                  [NSBundle mainBundle],
                                  @"Error",
                                  @"Error Common label");
        NSString *flightCommunityTitle = NSLocalizedStringWithDefaultValue(@"FLIGHT_COMMUNITY_TITLE",
                              nil,
                              [NSBundle mainBundle],
                              @"Flight %@ Community %f",
                              @"Flight {number} Community {date}");
        
        NSString *flightCommunityDesc = NSLocalizedStringWithDefaultValue(@"FLIGHT_COMMUNITY_DESCRIPTION",
                              nil,
                              [NSBundle mainBundle],
                              @"This community is created to enable discussion on flight %@. Here you can share about preparation and purpose for the trip.",
                              @"Flight Community description for flight {flight}");
        NSString *createCommunityResultSuccess = NSLocalizedStringWithDefaultValue(@"CREATE_COMMUNITY_101_RESULT_SUCCESS",
                              nil,
                              [NSBundle mainBundle],
                              @"Community is successfully created for flight 101",
                              @"Success creating flight community");
        NSString *createCommunityResultFailure = NSLocalizedStringWithDefaultValue(@"CREATE_COMMUNITY_101_RESULT_FAILURE",
                              nil,
                              [NSBundle mainBundle],
                              @"Community 101 can not be created.",
                              @"Success creating flight community");
        NSString *deleteCommunityResultSuccess = NSLocalizedStringWithDefaultValue(@"DELETE_COMMUNITY_101_RESULT_SUCCESS",
                              nil,
                              [NSBundle mainBundle],
                              @"Community 101 has been successfully deleted",
                              @"Success deleting flight community");
        NSString *deleteCommunityResultFailure = NSLocalizedStringWithDefaultValue(@"DELETE_COMMUNITY_101_RESULT_FAILURE",
                              nil,
                              [NSBundle mainBundle],
                              @"Community 101 can't be deleted",
                              @"Success deleting flight community");
        NSString *fileUploadSuccess = NSLocalizedStringWithDefaultValue(@"LOG_FILE_UPLOAD_SUCCESS",
                              nil,
                              [NSBundle mainBundle],
                              @"Log file named fb_log uploaded successfully",
                              @"Log file upload success");
        NSString *fileUploadFailure = NSLocalizedStringWithDefaultValue(@"LOG_FILE_UPLOAD_FAILURE",
                              nil,
                              [NSBundle mainBundle],
                              @"Could not upload the log file",
                              @"Log file upload failure");
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // Create a community
            NSString *key = @"101";
            UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
            SBTConnectionsCommunityService *comService = [[SBTConnectionsCommunityService alloc] init];
            SBTConnectionsCommunity *comm = [[SBTConnectionsCommunity alloc] init];
            comm.title = [NSString stringWithFormat:flightCommunityTitle, key, [[NSDate date] timeIntervalSince1970]];
            comm.content = [NSString stringWithFormat:flightCommunityDesc, key];
            comm.communityType = @"public";
            [comService createCommunity:comm success:^(SBTConnectionsCommunity *commmunity) {
                [SBTCredentialStore storeWithKey:key value:commmunity.communityUuid];
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:createCommunityResultSuccess delegate:nil cancelButtonTitle:nil otherButtonTitles:okLabel, nil];
                [alert show];
            } failure:^(NSError *error) {
                if (IS_DEBUGGING)
                    [FBLog log:[error description] from:self];
                
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorLabel message:createCommunityResultFailure delegate:nil cancelButtonTitle:nil otherButtonTitles:okLabel, nil];
                [alert show];
            }];
        } else if (indexPath.row == 1) {
            // Remove the community
            NSString *key = @"101";
            UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
            SBTConnectionsCommunityService *comService = [[SBTConnectionsCommunityService alloc] init];
            SBTConnectionsCommunity *comm = [[SBTConnectionsCommunity alloc] init];
            comm.communityUuid = [SBTCredentialStore loadWithKey:key];
            [comService deleteCommunity:comm success:^(BOOL success) {
                [SBTCredentialStore removeWithKey:key];
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:deleteCommunityResultSuccess delegate:nil cancelButtonTitle:nil otherButtonTitles:okLabel, nil];
                [alert show];
            } failure:^(NSError *error) {
                if (IS_DEBUGGING)
                    [FBLog log:[error description] from:self];
                
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorLabel message:deleteCommunityResultFailure delegate:nil cancelButtonTitle:nil otherButtonTitles:okLabel, nil];
                [alert show];
            }];
        }
    } else if (indexPath.section == 1) {
        // Upload log files to Connections File
        UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"fb_log"];
        NSData *content = [NSData dataWithContentsOfFile:filePath];
        SBTConnectionsFileService *fS = [[SBTConnectionsFileService alloc] initWithEndPointName:@"connections"];
        [fS uploadMultiPartFileWithContent:content
                                  fileName:[NSString stringWithFormat:@"%@.png", [[NSDate date] description]]
                                  mimeType:@"text/plain"
                                   success:^(id result) {
                                       [progressView dismissWithClickedButtonIndex:100 animated:YES];
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:fileUploadSuccess delegate:nil cancelButtonTitle:nil otherButtonTitles:okLabel, nil];
                                       [alert show];
                                   } failure:^(NSError *error) {
                                       [progressView dismissWithClickedButtonIndex:100 animated:YES];
                                       if (IS_DEBUGGING)
                                           [FBLog log:[error description] from:self];
                                       
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:fileUploadFailure delegate:nil cancelButtonTitle:nil otherButtonTitles:okLabel, nil];
                                       [alert show];
                                   }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) cancel {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
}

@end
