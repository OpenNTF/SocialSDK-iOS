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

//  This class is responsible for creating and returning EndPoints. For each endPointName,
//  there is only one EndPoint is created.

#import "IBMEndPointFactory.h"
#import "IBMConnectionsBasicEndPoint.h"
#import "IBMConnectionsOAuth2EndPoint.h"

@implementation IBMEndPointFactory

static NSString *IBM_SERVER_CONNECTIONS_BASIC = @"connections";
static NSString *IBM_SERVER_CONNECTIONS_OAUTH2 = @"connectionsOA2";
static NSString *IBM_SERVER_SMARTCLOUD = @"smartcloud";
static NSString *IBM_SERVER_SAMETIME = @"sametime";

+ (IBMEndPoint *) createEndPointWithName:(NSString *) endPointName {
    
    IBMEndPoint *endPoint = nil;
    if ([endPointName isEqualToString:IBM_SERVER_CONNECTIONS_BASIC]) {
        static dispatch_once_t pred;
        static IBMConnectionsBasicEndPoint *_sharedEndPoint = nil;
        dispatch_once(&pred, ^{
            _sharedEndPoint = [[IBMConnectionsBasicEndPoint alloc] init];
            _sharedEndPoint.endPointName = endPointName;
        });
        
        endPoint = _sharedEndPoint;
    } else if ([endPointName isEqualToString:IBM_SERVER_CONNECTIONS_OAUTH2]) {
        static dispatch_once_t pred;
        static IBMConnectionsOAuth2EndPoint *_sharedEndPoint = nil;
        dispatch_once(&pred, ^{
            _sharedEndPoint = [[IBMConnectionsOAuth2EndPoint alloc] init];
            _sharedEndPoint.endPointName = endPointName;
        });
        
        endPoint = _sharedEndPoint;
    } else if ([endPointName isEqualToString:IBM_SERVER_SMARTCLOUD]) {
        
    } else if ([endPointName isEqualToString:IBM_SERVER_SAMETIME]) {
        
    } else {
        // Default: Connections Basic
        static dispatch_once_t pred;
        static IBMConnectionsBasicEndPoint *_sharedEndPoint = nil;
        dispatch_once(&pred, ^{
            _sharedEndPoint = [[IBMConnectionsBasicEndPoint alloc] init];
            _sharedEndPoint.endPointName = endPointName;
        });
        
        endPoint = _sharedEndPoint;
    }
    
    return  endPoint;
}

@end
