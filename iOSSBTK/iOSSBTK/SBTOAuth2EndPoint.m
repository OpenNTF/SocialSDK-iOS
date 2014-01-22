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

#import "SBTOAuth2EndPoint.h"
#import "SBTConstants.h"
#import "SBTConnectionsActivityStreamService.h"
#import "FBLog.h"
#import "SBTCredentialStore.h"
#import "SBTHttpClient.h"

@implementation SBTOAuth2EndPoint

- (id) init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (NSString *) getAuthType {
    return OAUTH2;
}

- (void) initGetRequestWithPath:(NSString *) path
                     parameters:(NSDictionary *)param
                         format:(ResponseType)type
                        success:(void (^)(id, id))success
                        failure:(void (^)(id, NSError *))failure {
    
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:param
                                             format:type
                                            success:^(id response, id result) {
                                                success(response, result);
                                            } failure:^(id response, NSError *error) {
                                                failure(response, error);
                                            }];
}

- (void) initPostRequestWithPath:(NSString *) path
                         headers:(NSDictionary *) headers
                      parameters:(NSDictionary *)param
                          format:(ResponseType)type
                         success:(void (^)(id, id))success
                         failure:(void (^)(id, NSError *))failure {
    
    [[self getClientService] initPostRequestWithPath:path
                                             headers:(NSDictionary *) headers
                                          parameters:param
                                              format:type
                                             success:^(id response, id result) {
                                                 success(response, result);
                                             } failure:^(id response, NSError *error) {
                                                 failure(response, error);
                                             }];
}

- (void) initPutRequestWithPath:(NSString *) path
                        headers:(NSDictionary *) headers
                     parameters:(NSDictionary *)param
                         format:(ResponseType)type
                        success:(void (^)(id, id))success
                        failure:(void (^)(id, NSError *))failure {
    
    [[self getClientService] initPutRequestWithPath:path
                                            headers:(NSDictionary *) headers
                                         parameters:param
                                             format:type
                                            success:^(id response, id result) {
                                                success(response, result);
                                            } failure:^(id response, NSError *error) {
                                                failure(response, error);
                                            }];
}

- (void) initDeleteRequestWithPath:(NSString *) path
                        parameters:(NSDictionary *)param
                            format:(ResponseType)type
                           success:(void (^)(id, id))success
                           failure:(void (^)(id, NSError *))failure {
    
    [[self getClientService] initDeleteRequestWithPath:path
                                            parameters:param
                                                format:type
                                               success:^(id response, id result) {
                                                   success(response, result);
                                               } failure:^(id response, NSError *error) {
                                                   failure(response, error);
                                               }];
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
    
    [[self getClientService] initMultiPartFileUploadRequestWithPath:path
                                                           fileName:fileName
                                                           mimeType:mimeType
                                                            content:content
                                                            headers:headers
                                                         parameters:param
                                                             format:type
                                                            success:^(id response, id result) {
                                                                success(response, result);
                                                            } failure:^(id response, NSError *error) {
                                                                failure(response, error);
                                                            }];
}

@end
