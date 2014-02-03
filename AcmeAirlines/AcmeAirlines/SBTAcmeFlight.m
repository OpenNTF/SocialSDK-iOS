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

//  This class represent a flight entity

#import "SBTAcmeFlight.h"

@implementation SBTAcmeFlight


- (NSString *) description {
    
    NSString *flightDesc = NSLocalizedStringWithDefaultValue(@"FLIGHT_DESC",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Flight id: %@\n",
                                  @"Flight id: {flightId}\n");
    NSString *departureCityDesc = NSLocalizedStringWithDefaultValue(@"DEPARTURE_CITY_DESC",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Departure city: %@\n",
                                  @"Departure city: {departureCity}\n");
    NSString *arrivalCity = NSLocalizedStringWithDefaultValue(@"ARRIVAL_CITY_DESC",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Arrival city: %@\n",
                                  @"Arrival city: {arrivalCity}\n");
    NSString *departureTime = NSLocalizedStringWithDefaultValue(@"DEPARTURE_TIME_DESC",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Departure time: %@\n",
                                  @"Departure time: {departureTime}\n");
    NSString *flightTime = NSLocalizedStringWithDefaultValue(@"FLIGHT_TIME_DESC",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Flight time: %@\n",
                                  @"Flight time: {flightTime}\n");
    NSString *approver = NSLocalizedStringWithDefaultValue(@"APPROVER_DESC",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Approver: %@\n",
                                  @"Approver: {approver}\n");
    NSString *status = NSLocalizedStringWithDefaultValue(@"STATUS_DESC",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Status: %@\n",
                                  @"Status: {status}\n");
    NSString *checkedIn = NSLocalizedStringWithDefaultValue(@"CHECKEDIN_DESC",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"CheckedIn: %@\n",
                                  @"CheckedIn: {checkedIn}\n");
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:flightDesc, self.flightId];
    description = [description stringByAppendingFormat:departureCityDesc, self.departureCity];
    description = [description stringByAppendingFormat:arrivalCity, self.arrivalCity];
    description = [description stringByAppendingFormat:departureTime, self.departureTime];
    description = [description stringByAppendingFormat:flightTime, self.flightTime];
    description = [description stringByAppendingFormat:approver, self.approver];
    description = [description stringByAppendingFormat:status, self.status];
    description = [description stringByAppendingFormat:checkedIn, [self.checkedIn description]];
    
    return description;
}

@end
