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

#import <UIKit/UIKit.h>
#import "IBMConnectionsProfileService.h"

@interface SBTViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *listOfFlights;
@property (strong, nonatomic) NSMutableDictionary *flightStatus;
@property (strong, nonatomic) NSMutableDictionary *airportCodes;
@property (strong, nonatomic) IBMConnectionsProfile *myProfile;

@end
