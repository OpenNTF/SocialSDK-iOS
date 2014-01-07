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

//  This class is the main view designed for iPad

#import "IBMViewControllerIpad.h"
#import "IBMViewControllerIpadCell.h"
#import "IBMCredentialStore.h"
#import "IBMAcmeUtils.h"
#import "IBMAcmeConstant.h"
#import "IBMAcmeFlight.h"
#import "LoginView.h"
#import "IBMAcmeSettingsView.h"
#import "AFImageRequestOperation.h"
#import "IBMAcmeCommunityView.h"
#import "IBMCredentialStore.h"
#import "IBMConstants.h"
#import "IBMHttpClient.h"
#import "FBLog.h"
#import "IBMConnectionsBasicEndPoint.h"
#import "IBMAcmeMainViewCommonOperations.h"

@interface IBMViewControllerIpad ()

@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *imageNames;

@end

@implementation IBMViewControllerIpad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _titles = [IBMAcmeMainViewCommonOperations getTitles];
        _imageNames = [IBMAcmeMainViewCommonOperations getIconNames];
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
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(logout)];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showSettings)];
    self.navigationItem.rightBarButtonItem = logoutItem;
    self.navigationItem.leftBarButtonItem = settingsItem;
    
    [self.collectionView registerClass:[IBMViewControllerIpadCell class]
            forCellWithReuseIdentifier:@"IBMViewControllerIpadCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *connectionsUrl = [IBMCredentialStore loadWithKey:IBM_CREDENTIAL_CONNECTIONS_URL];
    NSString *acmeUrl = [IBMCredentialStore loadWithKey:IBM_CREDENTIAL_ACME_URL];
    
    if (connectionsUrl == nil || acmeUrl == nil) {
        // login is required
        [self performSelector:@selector(loginIsNeeded) withObject:nil afterDelay:0.2];
    } else {
        IBMConnectionsBasicEndPoint *endPoint = (IBMConnectionsBasicEndPoint *) [IBMEndPoint findEndPoint:@"connections"];
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
                    if (self.myProfile != [IBMAcmeUtils getMyProfileForce:NO]) {
                        self.myProfile = [IBMAcmeUtils getMyProfileForce:NO];
                    }
                }
            } else {
                [self performSelector:@selector(loginIsNeeded) withObject:nil afterDelay:0.2];
            }
        }];
    }
    
    [self.collectionView reloadData];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IBMViewControllerIpadCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"IBMViewControllerIpadCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    NSString *title = [self.titles objectAtIndex:(indexPath.section * 2 + indexPath.row)];;
    NSString *imageName = [self.imageNames objectAtIndex:(indexPath.section * 2 + indexPath.row)];;
    
    cell.titleLabel.text = title;
    if (indexPath.section == 1 && indexPath.row == 1) {
        [cell.imageView setBackgroundImage:[UIImage imageNamed:@"profile_photo_default.png"] forState:UIControlStateNormal];
        if (self.myProfile != nil && self.myProfile.thumbnailURL != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.myProfile.thumbnailURL]];
                if (imageData != nil) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        [cell.imageView setBackgroundImage:image forState:UIControlStateNormal];
                    });
                }
            });
        }
    } else {
        [cell.imageView setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    cell.imageView.tag = (indexPath.section * 2 + indexPath.row);
    [cell.imageView addTarget:self action:@selector(logoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void) logoAction:(id) sender {
    UIButton *button = (UIButton *) sender;
    
    if (button.tag == 0) {
        [IBMAcmeMainViewCommonOperations openFlightViewFor:self
                                                 myProfile:self.myProfile
                                             listOfFlights:self.listOfFlights
                                              airportCodes:self.airportCodes];
    } else if (button.tag == 1) {
        [IBMAcmeMainViewCommonOperations openMyFlightViewFor:self
                                                   myProfile:self.myProfile
                                               listOfFlights:self.listOfFlights];
    } else if (button.tag == 2) {
        [IBMAcmeMainViewCommonOperations openFlightStatusViewFor:self
                                                       myProfile:self.myProfile
                                                   listOfFlights:self.listOfFlights
                                                    airportCodes:self.airportCodes
                                                    flightStatus:self.flightStatus];
    } else if (button.tag == 3) {
        if (self.myProfile != nil) {
            [IBMAcmeMainViewCommonOperations openMyProfileViewFor:self
                                                        myProfile:self.myProfile];
        }
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval = CGSizeMake(245, 245);
    
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == 0) {
        //Portrait
        return UIEdgeInsetsMake(100,100,100,100);
    } else if(orientation == UIInterfaceOrientationPortrait) {
        //Portrait
        return UIEdgeInsetsMake(100,100,100,100);
    } else if(orientation == UIInterfaceOrientationLandscapeLeft) {
        // Left landscape
        return UIEdgeInsetsMake(50,200,50,200);
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        // Right landscape
        return UIEdgeInsetsMake(50,200,50,200);
    } else {
        return UIEdgeInsetsMake(100,100,100,100);
    }
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Helper methods
/**
 Internal method to to be executed when a login is neccessary
 */
- (void) loginIsNeeded {
    [IBMAcmeMainViewCommonOperations loginIsNeededForViewController:self];
}

/**
 This method is executed when user taps the logout bar button item
 */
- (void) logout {
    self.myProfile = nil;
    for (IBMAcmeFlight *flight in self.listOfFlights) {
        flight.status = @"";
        flight.approver = @"";
        flight.booked =[NSNumber numberWithBool:NO];
    }
    [IBMAcmeMainViewCommonOperations logoutForViewController:self
                                                   myProfile:self.myProfile
                                                     flights:self.listOfFlights];
}

/**
 This method opens the Settings view
 */
- (void) showSettings {
    IBMAcmeSettingsView *settings = [[IBMAcmeSettingsView alloc] init];
    settings.listOfFlights = self.listOfFlights;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:navController animated:YES completion:^(void) {
        
    }];
}

- (void) getMyProfile {
    self.myProfile = [IBMAcmeUtils getMyProfileForce:YES];
    [self.collectionView reloadData];
}

/**
 This method populate flights
 */
- (void) populateFlights {
    
    [IBMAcmeMainViewCommonOperations populateFlightsWithCompletionHandler:^(NSMutableArray *list) {
        if (list != nil) {
            self.listOfFlights = list;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not populate flights from server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}

/**
 This method populate airport codes
 */
- (void) populateAirportCodes {
    
    [IBMAcmeMainViewCommonOperations populateAirportCodesWithCompletionHandler:^(NSMutableDictionary *airportCodes) {
        if (airportCodes != nil) {
            self.airportCodes = airportCodes;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not populate ariport codes from server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}

/**
 This method populate flights' status
 */
- (void) populateFlightStatus {
    [IBMAcmeMainViewCommonOperations populateFlightStatusWithCompletionHandler:^(NSMutableDictionary *flightStatus) {
        if (flightStatus != nil) {
            self.flightStatus = flightStatus;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not populate flight status from server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}


@end
