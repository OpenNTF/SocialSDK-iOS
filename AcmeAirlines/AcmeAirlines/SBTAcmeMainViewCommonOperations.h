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

#import <Foundation/Foundation.h>
#import "SBTAcmeFlightView.h"
#import "SBTAcmeMyFlightView.h"
#import "SBTAcmeFlightStatusView.h"
#import "SBTAcmeMyProfileView.h"

@interface SBTAcmeMainViewCommonOperations : NSObject

/**
 This method returns the titles
 */
+ (NSMutableArray *) getTitles;

/**
 This method returns the icon names
 */

+ (NSMutableArray *) getIconNames;

/**
 This method push FlightView to the given controller
 @param viewController: controller to push
 @param myProfile: my profile information
 @param listOfFlights: list of flights populated from the Acme server
 @param airportCodes: airportcodes populated from the Acme server
 */
+ (void) openFlightViewFor:(UIViewController *) viewController
                 myProfile:(SBTConnectionsProfile *) myProfile
             listOfFlights:(NSMutableArray *) listOfFlights
              airportCodes:(NSMutableDictionary *) airportCodes;

/**
 This method push the MyFlightView to the given controller
 @param viewController: controller to push
 @param myProfile: my profile information
 @param listOfFlights: list of flights populated from the Acme server
 */
+ (void) openMyFlightViewFor:(UIViewController *) viewController
                   myProfile:(SBTConnectionsProfile *) myProfile
               listOfFlights:(NSMutableArray *) listOfFlights;

/**
 This method push FlightStatusView to the given controller
 @param viewController: controller to push
 @param myProfile: my profile information
 @param listOfFlights: list of flights populated from the Acme server
 @param flightStatus: dictionary of flight status
 */
+ (void) openFlightStatusViewFor:(UIViewController *) viewController
                       myProfile:(SBTConnectionsProfile *) myProfile
                   listOfFlights:(NSMutableArray *) listOfFlights
                    airportCodes:(NSMutableDictionary *) airportCodes
                    flightStatus:(NSMutableDictionary *) flightStatus;

/**
 This method push MyProfileView to the given controller
 @param viewController: controller to push
 @param myProfile: my profile information
 */
+ (void) openMyProfileViewFor:(UIViewController *) viewController
                    myProfile:(SBTConnectionsProfile *) myProfile;

/**
 To be executed when a login is neccessary
 */
+ (void) loginIsNeededForViewController:(UIViewController *) viewController;

/**
 To be executed when user taps the logout bar button item
 */
+ (void) logoutForViewController:(UIViewController *) viewController
                       myProfile:(SBTConnectionsProfile *) myProfile
                         flights:(NSMutableArray *) listOfFlights;

/**
 This method populate flights from the Acme Server
 */
+ (void) populateFlightsWithCompletionHandler:(void (^)(NSMutableArray *)) completionHandler;

/**
 This method populate airport codes from the Acme Server
 */
+ (void) populateAirportCodesWithCompletionHandler:(void (^)(NSMutableDictionary *)) completionHandler;

/**
 This method populate flights' status from the Acme Server
 */
+ (void) populateFlightStatusWithCompletionHandler:(void (^)(NSMutableDictionary *)) completionHandler;

@end
