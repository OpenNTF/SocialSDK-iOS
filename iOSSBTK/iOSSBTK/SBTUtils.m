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

#import "SBTUtils.h"
#import "SBTCredentialStore.h"
#import "SBTConstants.h"

@implementation SBTUtils

+ (BOOL) isEmail:(NSString *) str {
    if ([str rangeOfString:@"@"].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+ (NSString *) getUrlForEndPoint:(NSString *) endPointName {
    NSString *url = nil;
    if ([endPointName hasPrefix:@"connections"])
        url = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_CONNECTIONS_URL];
    else if ([endPointName hasPrefix:@"smartcloud"])
        url = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_SMARTCLOUD_URL];
    
    if (url == nil) {
        [NSException raise:@"Url Retrieval Error" format:@"You need to define a url for the endpoint first."];
    }
    
    return url;
}

@end
