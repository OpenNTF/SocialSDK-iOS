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

//  This class handles the common operations performed by the main view of the app

#import "SBTAcmeMainViewCommonOperations.h"
#import "LoginView.h"
#import "IBMConnectionsBasicEndPoint.h"
#import "SBTAcmeUtils.h"
#import "IBMHttpClient.h"
#import "IBMAcmeConstant.h"
#import "FBLog.h"

@implementation SBTAcmeMainViewCommonOperations

+ (NSMutableArray *) getTitles {
    NSMutableArray *listOfTitles = [[NSMutableArray alloc] initWithObjects:
               @"Flights",
               @"My Flights",
               @"Flight Status",
               @"My Profile",
               nil];
    return listOfTitles;
}

+ (NSMutableArray *) getIconNames {
    NSMutableArray *listOfImageNames = [[NSMutableArray alloc] initWithObjects:
                        @"flight_icon.png",
                        @"my_flights_blue.png",
                        @"flight_status.png",
                        @"about.png",
                        nil];
    return listOfImageNames;
}


+ (void) openFlightViewFor:(UIViewController *) viewController
                 myProfile:(IBMConnectionsProfile *) myProfile
             listOfFlights:(NSMutableArray *) listOfFlights
              airportCodes:(NSMutableDictionary *) airportCodes {
    SBTAcmeFlightView *flightView = [[SBTAcmeFlightView alloc] init];
    flightView.myProfile = myProfile;
    flightView.listOfFlights = listOfFlights;
    flightView.airportCodes = airportCodes;
    [viewController.navigationController pushViewController:flightView animated:YES];
}

+ (void) openMyFlightViewFor:(UIViewController *) viewController
                   myProfile:(IBMConnectionsProfile *) myProfile
               listOfFlights:(NSMutableArray *) listOfFlights {
    SBTAcmeMyFlightView *myFlight = [[SBTAcmeMyFlightView alloc] init];
    myFlight.listOfFlights = listOfFlights;
    myFlight.myProfile = myProfile;
    [viewController.navigationController pushViewController:myFlight animated:YES];
}

+ (void) openFlightStatusViewFor:(UIViewController *) viewController
                       myProfile:(IBMConnectionsProfile *) myProfile
                   listOfFlights:(NSMutableArray *) listOfFlights
                    airportCodes:(NSMutableDictionary *) airportCodes
                    flightStatus:(NSMutableDictionary *) flightStatus {
    SBTAcmeFlightStatusView *flightStatusView = [[SBTAcmeFlightStatusView alloc] init];
    flightStatusView.listOfFlights = listOfFlights;
    flightStatusView.airportCodes = airportCodes;
    flightStatusView.flightStatus = flightStatus;
    [viewController.navigationController pushViewController:flightStatusView animated:YES];
}

+ (void) openMyProfileViewFor:(UIViewController *) viewController
                    myProfile:(IBMConnectionsProfile *) myProfile {
    SBTAcmeMyProfileView *profileView = [[SBTAcmeMyProfileView alloc] init];
    profileView.myProfile = myProfile;
    profileView.comingFrom = @"IBMViewController";
    [viewController.navigationController pushViewController:profileView animated:YES];
}

+ (void) loginIsNeededForViewController:(UIViewController *) viewController {
    LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
    [viewController presentViewController:loginView animated:YES completion:^(void) {
        
    }];
}

+ (void) logoutForViewController:(UIViewController *) viewController
                       myProfile:(IBMConnectionsProfile *) myProfile
                         flights:(NSMutableArray *) listOfFlights {
    IBMConnectionsBasicEndPoint *endPoint = (IBMConnectionsBasicEndPoint *) [IBMEndPoint findEndPoint:@"connections"];
    [endPoint logout];
    
    [SBTAcmeMainViewCommonOperations loginIsNeededForViewController:viewController];
}

+ (void) populateFlightsWithCompletionHandler:(void (^)(NSMutableArray *)) completionHandler {
    NSMutableArray *listOfFlights = [[NSMutableArray alloc] init];
    NSURL *baseUrl = [NSURL URLWithString:[SBTAcmeUtils getAcmeUrl]];
    IBMHttpClient *httpClient = [[IBMHttpClient alloc] initWithBaseURL:baseUrl];
    NSString *path = [NSString stringWithFormat:@"/acme.social.sample.dataapp/rest/api/flights/all"];
    [httpClient getPath:path
             parameters:nil
                success:^(id response, id result) {
                    NSError *error = nil;
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&error];
                    NSMutableArray *flights = [jsonDict objectForKey:@"flights"];
                    for (NSDictionary *entry in flights) {
                        SBTAcmeFlight *flight = [[SBTAcmeFlight alloc] init];
                        flight.flightId = [entry valueForKey:@"Flight"];
                        flight.departureCity = [entry valueForKey:@"Depart"];
                        flight.arrivalCity = [entry valueForKey:@"Arrive"];
                        flight.departureTime = [entry valueForKey:@"Time"];
                        flight.flightTime = [entry valueForKey:@"FlightTime"];
                        [listOfFlights addObject:flight];
                    }
                    completionHandler(listOfFlights);
                } failure:^(id response, NSError *error) {
                    if (IS_DEBUGGING)
                        [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                    completionHandler(nil);
                }];
}

+ (void) populateAirportCodesWithCompletionHandler:(void (^)(NSMutableDictionary *)) completionHandler {
    NSMutableDictionary *airportCodes = [[NSMutableDictionary alloc] init];
    NSURL *baseUrl = [NSURL URLWithString:[SBTAcmeUtils getAcmeUrl]];
    IBMHttpClient *httpClient = [[IBMHttpClient alloc] initWithBaseURL:baseUrl];
    NSString *path = [NSString stringWithFormat:@"/acme.social.sample.dataapp/rest/api/airportcodes"];
    [httpClient getPath:path
             parameters:nil
                success:^(id response, id result) {
                    NSError *error = nil;
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&error];
                    NSArray *airports = [jsonDict objectForKey:@"airports"];
                    for (NSDictionary *entry in airports) {
                        NSString *city = [entry valueForKey:@"city"];
                        NSString *state = [entry valueForKey:@"state"];
                        NSString *code = [entry valueForKey:@"code"];
                        NSDictionary *pairs = [NSDictionary dictionaryWithObjectsAndKeys:
                                               city, @"city",
                                               state, @"state",
                                               nil];
                        [airportCodes setValue:pairs forKey:code];
                    }
                    
                    completionHandler(airportCodes);
                } failure:^(id response, NSError *error) {
                    if (IS_DEBUGGING)
                        [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                    completionHandler(nil);
                }];
}

+ (void) populateFlightStatusWithCompletionHandler:(void (^)(NSMutableDictionary *)) completionHandler {
    NSMutableDictionary *flightStatus = [[NSMutableDictionary alloc] init];
    NSURL *baseUrl = [NSURL URLWithString:[SBTAcmeUtils getAcmeUrl]];
    IBMHttpClient *httpClient = [[IBMHttpClient alloc] initWithBaseURL:baseUrl];
    NSString *path = [NSString stringWithFormat:@"/acme.social.sample.dataapp/rest/api/fc/all"];
    [httpClient getPath:path
             parameters:nil
                success:^(id response, id result) {
                    NSError *error = nil;
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&error];
                    NSMutableArray *flightSt = [jsonDict objectForKey:@"controller"];
                    for (NSDictionary *entry in flightSt) {
                        [flightStatus setValue:[entry objectForKey:@"State"] forKey:[entry objectForKey:@"Flight"]];
                    }
                    completionHandler(flightStatus);
                } failure:^(id response, NSError *error) {
                    if (IS_DEBUGGING)
                        [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                    completionHandler(nil);
                }];
}

@end
