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
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"Flight id: %@\n", self.flightId];
    description = [description stringByAppendingFormat:@"Departure city: %@\n", self.departureCity];
    description = [description stringByAppendingFormat:@"Arrival city: %@\n", self.arrivalCity];
    description = [description stringByAppendingFormat:@"Departure time: %@\n", self.departureTime];
    description = [description stringByAppendingFormat:@"Flight time: %@\n", self.flightTime];
    description = [description stringByAppendingFormat:@"Approver: %@\n", self.approver];
    description = [description stringByAppendingFormat:@"Status: %@\n", self.status];
    description = [description stringByAppendingFormat:@"CheckedIn: %@\n", [self.checkedIn description]];
    
    return description;
}

@end
