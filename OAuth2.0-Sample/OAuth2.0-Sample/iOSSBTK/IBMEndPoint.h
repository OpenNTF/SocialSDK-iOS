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

#import <Foundation/Foundation.h>
#import "IBMClientService.h"

@interface IBMEndPoint : NSObject

@property (strong, nonatomic) NSString *endPointName;

- (NSString *) getURL;
- (NSString *) getAuthType;

- (IBMClientService *) getClientService;

/**
 This method will return back the endpoint specified as a parameter
 @param endPointName
 */
+ (IBMEndPoint *) findEndPoint:(NSString *) endPointName;

/**
 This method initiate the get request.
 @param path: API for the request. This path to be added to the base url of the server.
 @param type: Response type to be fo be returned. Currently we support xml and json
 @param success: Success block to be called with the resulting object if the request is successful
 @param failure: Failure block to be called with an error object if the request fails
 */
- (void) initGetRequestWithPath:(NSString *) path
                     parameters:(NSDictionary *)param
                         format:(ResponseType)type
                        success:(void (^)(id, id))success
                        failure:(void (^)(id, NSError *))failure;

/**
 This method initiate the post request.
 @param path: API for the request. This path to be added to the base url of the server.
 @param headers: Header fields to be added to the http request
 @param type: Response type to be fo be returned. Currently we support xml and json
 @param success: Success block to be called with the resulting object if the request is successful
 @param failure: Failure block to be called with an error object if the request fails
 */
- (void) initPostRequestWithPath:(NSString *) path
                         headers:(NSDictionary *) headers
                      parameters:(NSDictionary *)param
                          format:(ResponseType)type
                         success:(void (^)(id, id))success
                         failure:(void (^)(id, NSError *))failure;

/**
 This method initiate the put request.
 @param path: API for the request. This path to be added to the base url of the server.
 @param headers: Header fields to be added to the http request
 @param type: Response type to be fo be returned. Currently we support xml and json
 @param success: Success block to be called with the resulting object if the request is successful
 @param failure: Failure block to be called with an error object if the request fails
 */
- (void) initPutRequestWithPath:(NSString *) path
                        headers:(NSDictionary *) headers
                     parameters:(NSDictionary *)param
                         format:(ResponseType)type
                        success:(void (^)(id, id))success
                        failure:(void (^)(id, NSError *))failure;

/**
 This method initiate the http delete request.
 @param path: API for the request. This path to be added to the base url of the server.
 @param type: Response type to be fo be returned. Currently we support xml and json
 @param success: Success block to be called with the resulting object if the request is successful
 @param failure: Failure block to be called with an error object if the request fails
 */
- (void) initDeleteRequestWithPath:(NSString *) path
                        parameters:(NSDictionary *)param
                            format:(ResponseType)type
                           success:(void (^)(id, id))success
                           failure:(void (^)(id, NSError *))failure;

/**
 This method initiate multi part file upload request.
 @param path: API for the request. This path to be added to the base url of the server.
 @param fileName: name of the file
 @param mimeType: type of the file such as application/pdf
 @param content: Content of the file to be uploaded; it should be formatted as either NSString or NSData
 @param headers: Header fields to be added to the http request
 @param param: Parameters to be used to construct the url
 @param type: Response type to be fo be returned. Currently we support xml and json
 @param success: Success block to be called with the resulting object if the request is successful
 @param failure: Failure block to be called with an error object if the request fails
 */
- (void) initMultiPartFileUploadRequestWithPath:(NSString *) path
                                       fileName:(NSString *) fileName
                                       mimeType:(NSString *) mimeType
                                        content:(id) content
                                        headers:(NSDictionary *) headers
                                     parameters:(NSDictionary *) param
                                         format:(ResponseType) type
                                        success:(void (^)(id, id)) success
                                        failure:(void (^)(id, NSError *)) failure;
@end
