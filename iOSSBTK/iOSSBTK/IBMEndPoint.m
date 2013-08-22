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

//  Base class for the EndPoint

#import "IBMEndPoint.h"
#import "IBMUtils.h"
#import "IBMEndPointFactory.h"

@implementation IBMEndPoint

- (NSString *) getURL {
    return [IBMUtils getUrlForEndPoint:self.endPointName];
}

- (NSString *) getAuthType {
    [NSException raise:@"Abstract method" format:@"This is an abstract method"];
    return nil;
}

- (IBMClientService *) getClientService {
    [NSException raise:@"This is an abstract method" format:@"This is an abstract method"];
    return nil;
}

+ (IBMEndPoint *) findEndPoint:(NSString *) endPointName {
    return [IBMEndPointFactory createEndPointWithName:endPointName];
}

- (void) initGetRequestWithPath:(NSString *) path
                     parameters:(NSDictionary *)param
                         format:(ResponseType)type
                        success:(void (^)(id, id))success
                        failure:(void (^)(id, NSError *))failure {
    [NSException raise:@"Abstract method" format:@"This is an abstract method"];
}


- (void) initPostRequestWithPath:(NSString *) path
                         headers:(NSDictionary *) headers
                      parameters:(NSDictionary *)param
                          format:(ResponseType)type
                         success:(void (^)(id, id))success
                         failure:(void (^)(id, NSError *))failure {
    [NSException raise:@"Abstract method" format:@"This is an abstract method"];
}


- (void) initPutRequestWithPath:(NSString *) path
                        headers:(NSDictionary *) headers
                     parameters:(NSDictionary *)param
                         format:(ResponseType)type
                        success:(void (^)(id, id))success
                        failure:(void (^)(id, NSError *))failure {
    [NSException raise:@"Abstract method" format:@"This is an abstract method"];
}


- (void) initDeleteRequestWithPath:(NSString *) path
                        parameters:(NSDictionary *)param
                            format:(ResponseType)type
                           success:(void (^)(id, id))success
                           failure:(void (^)(id, NSError *))failure {
    [NSException raise:@"Abstract method" format:@"This is an abstract method"];
}

- (void) initMultiPartFileUploadRequestWithPath:(NSString *) path
                                       fileName:(NSString *) fileName
                                       mimeType:(NSString *) mimeType
                                        content:(id) content
                                        headers:(NSDictionary *) headers
                                     parameters:(NSDictionary *) param
                                         format:(ResponseType) type
                                        success:(void (^)(id, id)) success
                                        failure:(void (^)(id, NSError *)) failure {
    [NSException raise:@"Abstract method" format:@"This is an abstract method"];
}

@end
