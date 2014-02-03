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

//  This is the main view of the Acme Sample App

#import "SBTViewController.h"
#import "SBTAcmeConstant.h"
#import "GDataXMLNode.h"
#import <iOSSBTK/SBTConnectionsCommunityService.h>
#import <iOSSBTK/SBTConnectionsActivityStreamService.h>
#import <iOSSBTK/SBTActivityStreamEntry.h>
#import <iOSSBTK/SBTConnectionsFileService.h>
#import <iOSSBTK/SBTEndPointFactory.h>
#import "SBTAppDelegate.h"
#import "LoginView.h"
#import <iOSSBTK/SBTCredentialStore.h>
#import "SBTAcmeUtils.h"
#import "SBTAcmeCommunityView.h"
#import "SBTAcmeSettingsView.h"
#import <iOSSBTK/SBTCredentialStore.h>
#import <iOSSBTK/SBTConstants.h>
#import <iOSSBTK/FBLog.h>
#import <iOSSBTK/SBTHttpClient.h>
#import <QuartzCore/QuartzCore.h>
#import <iOSSBTK/SBTConnectionsBasicEndPoint.h>
#import "SBTAcmeMainViewCommonOperations.h"

@interface SBTViewController ()

@property (strong, nonatomic) NSMutableArray *listOfTitles;
@property (strong, nonatomic) NSMutableArray *listOfIcons;

@end

@implementation SBTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _listOfTitles = [SBTAcmeMainViewCommonOperations getTitles];
        _listOfIcons = [SBTAcmeMainViewCommonOperations getIconNames];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Acme Airlines";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:90.0/255
                                                                        green:91.0/255
                                                                         blue:71.0/255
                                                                        alpha:1];
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:
                                                                  NSLocalizedStringWithDefaultValue(@"LOGOUT",
                                                                      @"Common",
                                                                      [NSBundle mainBundle],
                                                                      @"Logout",
                                                                      @"Logout")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(logout)];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithTitle:
                                                                    NSLocalizedStringWithDefaultValue(@"SETTINGS",
                                                                      @"Common",
                                                                      [NSBundle mainBundle],
                                                                      @"Settings",
                                                                      @"Settings common label")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showSettings)];
    self.navigationItem.rightBarButtonItem = logoutItem;
    self.navigationItem.leftBarButtonItem = settingsItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *connectionsUrl = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_CONNECTIONS_URL];
    NSString *acmeUrl = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_ACME_URL];
    
    if (connectionsUrl == nil || acmeUrl == nil) {
        // login is required
        [self performSelector:@selector(loginIsNeeded) withObject:nil afterDelay:0.2];
    } else {
        SBTConnectionsBasicEndPoint *endPoint = (SBTConnectionsBasicEndPoint *) [SBTEndPoint findEndPoint:@"connections"];
        [endPoint isAuthenticatedWithCompletionHandler:^(NSError *error) {
            if (error == nil) {
                if (self.airportCodes == nil)
                    [self performSelector:@selector(populateAirportCodes) withObject:nil afterDelay:0.2];
                if (self.flightStatus == nil)
                    [self performSelector:@selector(populateFlightStatus) withObject:nil afterDelay:0.2];
                if (self.listOfFlights == nil)
                    [self performSelector:@selector(populateFlights) withObject:nil afterDelay:0.2];
                if (self.myProfile == nil) {
                    [self performSelector:@selector(getMyProfile) withObject:nil afterDelay:0.2];
                } else {
                    if (self.myProfile != [SBTAcmeUtils getMyProfileForce:NO]) {
                        self.myProfile = [SBTAcmeUtils getMyProfileForce:NO];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }
            } else {
                [self performSelector:@selector(loginIsNeeded) withObject:nil afterDelay:0.2];
            }
        }];
    }
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
    return [self.listOfTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section
{
    if (section == 0)
        return 70;
    else
        return 10;
}


- (UIView *) tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        
        CGRect windowBounds = [[UIScreen mainScreen] bounds];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windowBounds.size.width, 90)];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Handle Auto Layout constraints
        NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:50];
        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:imageView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:50];
        NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:view
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1
                                                                        constant:0];
        NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:imageView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:view
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0];
        [view addConstraints:[NSArray arrayWithObjects:constraintWidth, constraintHeight, constraintX, constraintY, nil]];
        imageView.image = [UIImage imageNamed:@"header.png"];
        [view addSubview:imageView];
        
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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.tag = 1;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 5;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + 10 + imageView.frame.size.width + 10, 15, 200, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:TEXT_SIZE];
        titleLabel.tag = 2;
        
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:titleLabel];
    }
    
    UIImageView *imageView = (UIImageView *) [cell.contentView viewWithTag:1];
    
    if (indexPath.section != 3) {
        imageView.image = [UIImage imageNamed:[self.listOfIcons objectAtIndex:indexPath.section]];
    } else {
        if (self.myProfile != nil && self.myProfile.thumbnailURL != nil) {
            // This sometimes returns a cached image need to look at that.
            [SBTAcmeUtils downloadAndSetImage:imageView url:self.myProfile.thumbnailURL];
        }
    }
    
    UILabel *titleLabel = (UILabel *) [cell.contentView viewWithTag:2];
    titleLabel.text = [self.listOfTitles objectAtIndex:indexPath.section];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [SBTAcmeMainViewCommonOperations openFlightViewFor:self
                                                 myProfile:self.myProfile
                                             listOfFlights:self.listOfFlights
                                              airportCodes:self.airportCodes];
    } else if (indexPath.section == 1) {
        [SBTAcmeMainViewCommonOperations openMyFlightViewFor:self
                                                   myProfile:self.myProfile
                                               listOfFlights:self.listOfFlights];
    } else if (indexPath.section == 2) {
        [SBTAcmeMainViewCommonOperations openFlightStatusViewFor:self
                                                       myProfile:self.myProfile
                                                   listOfFlights:self.listOfFlights
                                                    airportCodes:self.airportCodes
                                                    flightStatus:self.flightStatus];
    } else if (indexPath.section == 3) {
        if (self.myProfile != nil) {
            [SBTAcmeMainViewCommonOperations openMyProfileViewFor:self
                                                        myProfile:self.myProfile];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helper methods
/**
 Internal method to to be executed when a login is neccessary
 */
- (void) loginIsNeeded {
    [SBTAcmeMainViewCommonOperations loginIsNeededForViewController:self];
}

/**
 This method is executed when user taps the logout bar button item
 */
- (void) logout {
    self.myProfile = nil;
    for (SBTAcmeFlight *flight in self.listOfFlights) {
        flight.status = @"";
        flight.approver = @"";
        flight.booked =[NSNumber numberWithBool:NO];
    }
    [SBTAcmeMainViewCommonOperations logoutForViewController:self
                                                   myProfile:self.myProfile
                                                     flights:self.listOfFlights];
}

/**
 This method opens the Settings view
 */
- (void) showSettings {
    SBTAcmeSettingsView *settings = [[SBTAcmeSettingsView alloc] init];
    settings.listOfFlights = self.listOfFlights;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:navController animated:YES completion:^(void) {
        
    }];
}

- (void) getMyProfile {
    self.myProfile = [SBTAcmeUtils getMyProfileForce:YES];
    [self.tableView reloadData];
}

/**
 This method populate flights
 */
- (void) populateFlights {
    
    [SBTAcmeMainViewCommonOperations populateFlightsWithCompletionHandler:^(NSMutableArray *list) {
        if (list != nil) {
            self.listOfFlights = list;
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:
                                    NSLocalizedStringWithDefaultValue(@"ERROR",
                                      @"Common",
                                      [NSBundle mainBundle],
                                      @"Error",
                                      @"Error Common label")
                                  message:
                                   NSLocalizedStringWithDefaultValue(@"NO_FLIGHTS_FROM_SERVER",
                                      nil,
                                      [NSBundle mainBundle],
                                      @"Could not populate flights from server",
                                      @"Could not populate flights from server")
                                  delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:
                                    NSLocalizedStringWithDefaultValue(@"OK",
                                      @"Common",
                                      [NSBundle mainBundle],
                                      @"OK",
                                      @"OK Common label"),
                                  nil];
            [alert show];
        }
    }];
}

/**
 This method populate airport codes
 */
- (void) populateAirportCodes {
    
    [SBTAcmeMainViewCommonOperations populateAirportCodesWithCompletionHandler:^(NSMutableDictionary *airportCodes) {
        if (airportCodes != nil) {
            self.airportCodes = airportCodes;
        } else {
           UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:
                                    NSLocalizedStringWithDefaultValue(@"ERROR",
                                      @"Common",
                                      [NSBundle mainBundle],
                                      @"Error",
                                      @"Error Common label")
                                  message:
                                    NSLocalizedStringWithDefaultValue(@"NO_AIRPORT_CODES_FROM_SERVER",
                                      nil,
                                      [NSBundle mainBundle],
                                      @"Could not populate airport codes from server",
                                      @"Could not populate airport codes from server")
                                  delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:
                                    NSLocalizedStringWithDefaultValue(@"OK",
                                      @"Common",
                                      [NSBundle mainBundle],
                                      @"OK",
                                      @"OK Common label"),
                                  nil]; 
            [alert show];
        }
    }];
}

/**
 This method populate flights' status
 */
- (void) populateFlightStatus {
    [SBTAcmeMainViewCommonOperations populateFlightStatusWithCompletionHandler:^(NSMutableDictionary *flightStatus) {
        if (flightStatus != nil) {
            self.flightStatus = flightStatus;
        } else {
           UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:
                                    NSLocalizedStringWithDefaultValue(@"ERROR",
                                      @"Common",
                                      [NSBundle mainBundle],
                                      @"Error",
                                      @"Error Common label")
                                  message:
                                    NSLocalizedStringWithDefaultValue(@"NO_FLIGHT_STATUS_FROM_SERVER",
                                      nil,
                                      [NSBundle mainBundle],
                                      @"Could not populate flight status from server",
                                      @"Could not populate flight status from server")
                                  delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:
                                    NSLocalizedStringWithDefaultValue(@"OK",
                                      @"Common",
                                      [NSBundle mainBundle],
                                      @"OK",
                                      @"OK Common label"),
                                  nil];
            [alert show];
        }
    }];
}

@end
