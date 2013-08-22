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

#import "IBMASApplication.h"

@implementation IBMASApplication

+ (NSString*) convertToString:(AS_APPLICATION_TYPE) type {
    NSString *result = nil;
    
    switch(type) {
        case A_COMMUNITIES:
            result = @"@communities";
            break;
        case A_TAGS:
            result = @"@tags";
            break;
        case A_PEOPLE:
            result = @"@people";
            break;
        case A_STATUS:
            result = @"@status";
            break;
        case A_ALL:
            result = @"@all";
            break;
        case A_NOAPP:
            result = @"@NOAPP";
            break;
        default:
            result = @"all";
    }
    
    return result;
}

@end
