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

#import "IBMBaseService.h"
#import "IBMEndPointFactory.h"

@interface IBMBaseService ()

@property (strong, nonatomic) NSString *endPointName;

@end

@implementation IBMBaseService

static NSString *DEFAULT_ENDPOINT_NAME = @"connections";

- (id) init {
    if (self = [super init]) {
        self.endPointName = DEFAULT_ENDPOINT_NAME;
        [self createEndPoint];
    }
    
    return self;
}

- (id) initWithEndPointName:(NSString *) endPointName {
    if (self = [super init]) {
        // Create and set the endpoint in here
        self.endPointName = endPointName;
        [self createEndPoint];
    }
    
    return self;
}

- (void) createEndPoint {
    // Create end point here
    self.endPoint = [IBMEndPointFactory createEndPointWithName:self.endPointName];
}

- (IBMClientService *) getClientService {
    return [self.endPoint getClientService];
}

@end
