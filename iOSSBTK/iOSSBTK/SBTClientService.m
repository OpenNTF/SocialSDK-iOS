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

//  This class is used for the base for http operations: get, post and put. We use AFNetworking as a wrapper
//  library but we could change it if we needed. This class actually serves as a wrapper for AFNetworking.

#import "SBTClientService.h"
#import "SBTXMLDocument.h"
#import "AFHTTPRequestOperation.h"
#import "SBTConnectionsFileService.h"
#import "SBTCredentialStore.h"
#import "SBTHttpClient.h"
#import "FBLog.h"
#import "SBTConstants.h"
#import "SBTOAuth2EndPoint.h"

@interface SBTClientService ()

@property (strong, nonatomic) SBTHttpClient *httpClient;

@end

@implementation SBTClientService

- (id) init {
    if (self = [super init]) {
        [self initializeEnv];
    }
    
    return self;
}

- (id) initWithEndPoint:(SBTEndPoint *) endPoint {
    if (self = [super init]) {
        self.endPoint = endPoint;
        [self initializeEnv];
    }
    
    return self;
}

- (void) initializeEnv {
    
    if ([[self.endPoint getAuthType] isEqualToString:BASICAUTH]){
        // Basic authentication
        self.httpClient = [[SBTHttpClient alloc] initWithBaseURL:[NSURL URLWithString:[SBTUtils getUrlForEndPoint:self.endPoint.endPointName]]];
        NSString *userName = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_USERNAME];
        NSString *password = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_PASSWORD];
        if (userName != nil && password != nil)
            [self.httpClient setUsername:userName andPassword:password];
        else
            [NSException raise:@"Authentication Problem" format:@"Username or password is not set yet (IBMClientService)"];
    } else if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        // OAUTH2
        NSString *accessToken = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_OAUTH2_TOKEN];
        if (accessToken != nil) {
            // Here check if a re-authorization is needed
            if ([self reAuthorizationIsNeededForOAuth] == NO) {
                self.httpClient = [[SBTHttpClient alloc] initWithBaseURL:[NSURL URLWithString:[SBTUtils getUrlForEndPoint:self.endPoint.endPointName]]];
                [self.httpClient setDefaultHeader:@"Authorization"
                                            value:[NSString stringWithFormat:@"Bearer %@", accessToken]];
            }
        } else {
            [NSException raise:@"Authentication Problem" format:@"Access Token is not provided (IBMClientService)"];
        }
        
    } else {
        [NSException raise:@"Authentication Problem" format:@"Unknown authentication format (IBMClientService)"];
    }
}

/**
 Here check if a reauthorization is needed.
 We should check if the access token is expired. If it is then we need to retrieve a new one.
 */
#warning Incomplete implementation
- (BOOL) reAuthorizationIsNeededForOAuth {
    return NO;
}

- (void) initGetRequestWithPath:(NSString *) path
                     parameters:(NSDictionary *) param
                         format:(ResponseType) type
                        success:(void (^)(id, id)) success
                        failure:(void (^)(id, NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK) {
        [FBLog log:[NSString stringWithFormat:@"initiating get request with path: %@ paramaters: %@", path, [param description]] from:self];
    }
    
    
    [self.httpClient getPath:path parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id formattedResult = [self processResponseWithFormat:type data:responseObject];
        if (formattedResult == nil && type != RESPONSE_NONE) {
            failure(operation.response, [NSError errorWithDomain:@"SBTClientService"
                                        code:100
                                    userInfo:[NSDictionary dictionaryWithObject:@"Error while formatting the file to the required file format" forKey:@"description"]]);
        } else {
            
            success(operation.response, formattedResult);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(operation.response, error);
    }];
}

- (void) initPostRequestWithPath:(NSString *) path
                         headers:(NSDictionary *) headers
                     parameters:(NSDictionary *) param
                          format:(ResponseType) type
                        success:(void (^)(id, id)) success
                        failure:(void (^)(id, NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK) {
        [FBLog log:[NSString stringWithFormat:@"initiating post request with path: %@ paramaters: %@", path, [param description]] from:self];
    }
    
    // Set the headers here
    for (NSString *key in headers) {
        [self.httpClient setDefaultHeader:key value:[headers objectForKey:key]];
    }
    
    [self.httpClient postPath:path parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id formattedResult = [self processResponseWithFormat:type data:responseObject];
        if (formattedResult == nil && type != RESPONSE_NONE) {
            failure(operation.response, [NSError errorWithDomain:@"SBTClientService"
                                                            code:100
                                                        userInfo:[NSDictionary dictionaryWithObject:@"Error while formatting the file to the required file format" forKey:@"description"]]);
        } else {
            success(operation.response, formattedResult);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        failure(operation.response, error);
    }];
}

- (void) initPutRequestWithPath:(NSString *) path
                        headers:(NSDictionary *) headers
                      parameters:(NSDictionary *) param
                         format:(ResponseType) type
                         success:(void (^)(id, id)) success
                         failure:(void (^)(id, NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK) {
        [FBLog log:[NSString stringWithFormat:@"initiating put request with path: %@ paramaters: %@", path, [param description]] from:self];
    }

    // Set the headers here
    for (NSString *key in headers) {
        [self.httpClient setDefaultHeader:key value:[headers objectForKey:key]];
    }
    
    [self.httpClient putPath:path parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id formattedResult = [self processResponseWithFormat:type data:responseObject];
        if (formattedResult == nil && type != RESPONSE_NONE) {
            failure(operation.response, [NSError errorWithDomain:@"SBTClientService"
                                                            code:100
                                                        userInfo:[NSDictionary dictionaryWithObject:@"Error while formatting the file to the required file format" forKey:@"description"]]);
        } else {
            success(operation.response, formattedResult);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(operation.response, error);
    }];
}

- (void) initDeleteRequestWithPath:(NSString *) path
                     parameters:(NSDictionary *) param
                         format:(ResponseType) type
                        success:(void (^)(id, id)) success
                        failure:(void (^)(id, NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK) {
        [FBLog log:[NSString stringWithFormat:@"initiating delete request with path: %@ paramaters: %@", path, [param description]] from:self];
    }

    [self.httpClient deletePath:path parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id formattedResult = [self processResponseWithFormat:type data:responseObject];
        if (formattedResult == nil && type != RESPONSE_NONE) {
            failure(operation.response, [NSError errorWithDomain:@"SBTClientService"
                                                            code:100
                                                        userInfo:[NSDictionary dictionaryWithObject:@"Error while formatting the file to the required file format" forKey:@"description"]]);
        } else {
            success(operation.response, formattedResult);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(operation.response, error);
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
    
    // Set the headers here
    for (NSString *key in headers) {
        [self.httpClient setDefaultHeader:key value:[headers objectForKey:key]];
    }
    
    NSData *contentOfFile;
    if ([content isKindOfClass:[NSString class]]) {
        contentOfFile = [content dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([content isKindOfClass:[NSData class]]) {
        contentOfFile = content;
    } else {
        NSString *errorDescription = [NSString stringWithFormat:@"Given body object is a kind of class: %@. However, body needs to be either NSString or NSData.", [content class]];
        if (IS_DEBUGGING_SBTK)
            [FBLog log:errorDescription from:self];
        failure(nil, [NSError errorWithDomain:@"SBTClientService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObject:errorDescription
                                                                     forKey:@"description"]]);
        return;
    }
    
    NSMutableURLRequest *request = [self.httpClient multipartFormRequestWithMethod:@"POST"
                                                                              path:path
                                                                        parameters:param
                                                         constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                             [formData appendPartWithFileData:content
                                                                                         name:@"file"
                                                                                     fileName:fileName
                                                                                     mimeType:mimeType];
                                                         }];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
        
        id formattedResult = [self processResponseWithFormat:type data:response];
        if (formattedResult == nil && type != RESPONSE_NONE) {
            failure(operation.response, [NSError errorWithDomain:@"SBTClientService"
                                                            code:100
                                                        userInfo:[NSDictionary dictionaryWithObject:@"Error while formatting the file to the required file format" forKey:@"description"]]);
        } else {
            success(operation.response, formattedResult);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(operation, error);
    }];
    
    
    if (IS_DEBUGGING_SBTK) {
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            if (IS_DEBUGGING_SBTK) {
                [FBLog log:[NSString stringWithFormat:@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite] from:self];
            }
        }];
    }
    
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

- (id) processResponseWithFormat:(ResponseType) type data:(NSData *) data {
    
    if (type == RESPONSE_XML) {
        return [self processXMLResponseWithData:data];
    } else if (type == RESPONSE_JSON) {
        return [self processJSONResponseWithData:data];
    } else if (type == RESPONSE_NONE) {
        return data;
    } else if (type == RESPONSE_TEXT) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];;
    } else {
        return [self processXMLResponseWithData:data];
    }
    
    return nil;
}

- (id) processXMLResponseWithData:(id) data {
    NSError *error;
    SBTXMLDocument *doc = [[SBTXMLDocument alloc] initWithData:(NSData *) data options:0 error:&error];
    
    if (doc == nil) {
        
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"Error while parsing: %@", [error description]] from:self];
        
        return nil;
    }
    
    return doc;
}

- (id) processJSONResponseWithData:(id) data {
    
    NSError *error;
    id processedResult = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error != nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"Error while parsing: %@", [error description]] from:self];
        
        return nil;
    }
    
    return processedResult;
}

@end
