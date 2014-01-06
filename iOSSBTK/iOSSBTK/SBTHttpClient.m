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

#import "SBTHttpClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFJSONRequestOperation.h"
#import "SBTUtils.h"
#import "FBLog.h"
#import "SBTConstants.h"

@implementation SBTHttpClient

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    return self;
}

- (void)setUsername:(NSString *)username andPassword:(NSString *)password {
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}

+ (void) deleteLtpaToken {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[SBTUtils getUrlForEndPoint:@"connections"]]];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

#pragma mark - Overrided method for manually inserting body parameters for the post and put request

- (NSMutableURLRequest *) requestWithMethod:(NSString *) method
                                      path:(NSString *) path
                                parameters:(NSDictionary *) parameters {
    
    NSMutableURLRequest *request;
    if ([method isEqualToString:@"PUT"] || [method isEqualToString:@"POST"]) {
        if (parameters != nil) {
            path = [path stringByAppendingString:@"?"];
            // Add parameters to the url
            for (NSString *key in parameters) {
                if (![key isEqualToString:@"body"]) {
                    path = [path stringByAppendingFormat:@"%@=%@&", key, [parameters objectForKey:key]];
                }
            }
            // Remove the last &
            path = [path substringToIndex:(path.length-1)];
        }
        
        request = [super requestWithMethod:method path:path parameters:nil];
        id body = [parameters objectForKey:@"body"];
        if (body != nil) {
            if ([body isKindOfClass:[NSString class]]) {
                [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
            } else if ([body isKindOfClass:[NSData class]]) {
                [request setHTTPBody:body];
            } else {
                if (IS_DEBUGGING_SBTK)
                    [FBLog log:[NSString stringWithFormat:@"Given body object is a kind of class: %@. However, body needs to be either NSString or NSData.", [body class]] from:self];
                return nil;
            }
        }
    } else {
         request = [super requestWithMethod:method path:path parameters:parameters];
    }
    
    return request;
}

@end
