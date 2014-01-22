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

#import <Foundation/Foundation.h>

@interface SBTAcmeFlight : NSObject

#pragma mark - Properties

@property (strong, nonatomic) NSString *flightId;
@property (strong, nonatomic) NSString *departureCity;
@property (strong, nonatomic) NSString *arrivalCity;
@property (strong, nonatomic) NSString *departureTime;
@property (strong, nonatomic) NSString *flightTime;// in hour
@property (strong, nonatomic) NSString *approver;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSNumber *checkedIn;
@property (strong, nonatomic) NSNumber *booked;
@property (strong, nonatomic) NSNumber *isBooking;

#pragma mark - Methods

- (NSString *) description;

@end
