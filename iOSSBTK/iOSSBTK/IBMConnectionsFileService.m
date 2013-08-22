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

#import "IBMConnectionsFileService.h"
#import "IBMXMLDocument.h"
#import "IBMConstants.h"
#import "FBLog.h"

@implementation IBMConnectionsFileService

const NSString *FILES_URL = @"/files";

typedef enum {
    F_MY_FAVORITES,
    F_MY_USER_LIBRARY
} F_CATEGORY_TYPE;

typedef enum {
    F_FEED,
    F_MEDIA,
    F_ENTRY,
    F_REPORTS,
    F_NONCE,
    F_LOCK_,
    F_NULL
} F_RESULT_TYPE;

typedef enum {
    F_FILES,
    F_FOLDERS,
    F_RECYCLE_BIN
} F_VIEW_TYPE;

typedef enum {
    F_ADDEDTO,
    F_SHARE,
    F_SHARED,
    F_MY_SHARES,
    F_COMMENT,
    F_NULL_FILTER,
} F_FILTER_TYPE;

- (id) init {
    if (self = [super initWithEndPointName:@"connections"]) {
        
    }
    
    return self;
}

- (id) initWithEndPointName:(NSString *)endPointName {
    if (self = [super initWithEndPointName:endPointName]) {
        
    }
    
    return self;
}

#pragma mark - API Services


- (void) getFileWithFileId:(NSString *) fileId
                parameters:(NSMutableDictionary *) parameters
                   success:(void (^)(IBMFileEntry *)) success
                   failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting file: %@ with parameters: %@", fileId, [parameters description]] from:self];
    
    if (fileId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"file id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"file id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/document/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      fileId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                
                                                if (((IBMXMLDocument *)result) != nil) {
                                                    IBMFileEntry *file = [[IBMFileEntry alloc] initWithXMLDocument:result];
                                                    
                                                    success(file);
                                                } else {
                                                    failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                                                                code:100
                                                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"file not found", @"description", nil]]);
                                                }
     
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
    
}

- (void) getMyFilesWithParameters:(NSMutableDictionary *) parameters
                          success:(void (^)(NSMutableArray *)) success
                          failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my files with parameters: %@", [parameters description]] from:self];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getFilesSharedWithMeWithParameters:(NSMutableDictionary *) parameters
                                   success:(void (^)(NSMutableArray *)) success
                                   failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting files shared with me with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:@"inbound" forKey:DIRECTION];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithViewType:F_FILES],
                      [self convertToStringWithFilterType:F_SHARED],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getFilesSharedByMeWithParameters:(NSMutableDictionary *) parameters
                                 success:(void (^)(NSMutableArray *)) success
                                 failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting files shared by me with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:@"outbound" forKey:DIRECTION];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithViewType:F_FILES],
                      [self convertToStringWithFilterType:F_SHARED],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];

}

- (void) getPublicFilesWithParameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting public files with parameters: %@", [parameters description]] from:self];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:@"public" forKey:VISIBILITY];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/anonymous/api/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithViewType:F_FILES],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getPinnedFilesWithParameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting pinned files with parameters: %@", [parameters description]] from:self];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_FAVORITES],
                      [self convertToStringWithViewType:F_FILES],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getMyFoldersWithParameters:(NSMutableDictionary *) parameters
                            success:(void (^)(NSMutableArray *)) success
                            failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my folders with parameters: %@", [parameters description]] from:self];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithViewType:F_FOLDERS],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getMyPinnedFoldersWithParameters:(NSMutableDictionary *) parameters
                            success:(void (^)(NSMutableArray *)) success
                            failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my pinned folders with parameters: %@", [parameters description]] from:self];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_FAVORITES],
                      [self convertToStringWithViewType:F_FOLDERS],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getFoldersWithRecentlyAddedFilesWithParameters:(NSMutableDictionary *) parameters
                                                success:(void (^)(NSMutableArray *)) success
                                                failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting folders with recently added files with parameters: %@", [parameters description]] from:self];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithViewType:F_FOLDERS],
                      [self convertToStringWithFilterType:F_ADDEDTO],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getFilesInFolderWithCollectionId:(NSString *) collectionId
                               parameters:(NSMutableDictionary *) parameters
                                  success:(void (^)(NSMutableArray *)) success
                                  failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting files in folder: %@ with parameters: %@", collectionId, [parameters description]] from:self];
    
    if (collectionId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"collection id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"collection id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/collection/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      collectionId,
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getPublicFileFoldersWithParameters:(NSMutableDictionary *) parameters
                                    success:(void (^)(NSMutableArray *)) success
                                    failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting public folders with parameters: %@", [parameters description]] from:self];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/anonymous/api/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithViewType:F_FOLDERS],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];

}

- (void) getPersonLibraryWithUserId:(NSString *) userId
                       parameters:(NSMutableDictionary *) parameters
                          success:(void (^)(NSMutableArray *)) success
                          failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting library of a user: %@ with parameters: %@", userId, [parameters description]] from:self];
    
    if (userId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"user id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"user id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/anonymous/api/userlibrary/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      userId,
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getCommentsForPublicFile:(IBMFileEntry *) file
                        withParameters:(NSMutableDictionary *) parameters
                               success:(void (^)(NSMutableArray *)) success
                               failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting public files comments for the file: %@ with parameters: %@", [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || file.personEntry.userUuid == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File, file id or author id cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:@"comment" forKey:CATEGORY];
    NSString *path = [NSString stringWithFormat:@"%@/%@/anonymous/api/userlibrary/%@/document/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      file.personEntry.userUuid,
                      file.fileId,
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertCommentListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getCommentsForFile:(IBMFileEntry *) file
             withParameters:(NSMutableDictionary *) parameters
                    success:(void (^)(NSMutableArray *)) success
                    failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting comments for the file: %@ with parameters: %@", [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || file.personEntry.userUuid == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File, file id or author id cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:@"comment" forKey:CATEGORY];
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/userlibrary/%@/document/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      file.personEntry.userUuid,
                      file.fileId,
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertCommentListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getMyCommentsForFile:(IBMFileEntry *) file
               withParameters:(NSMutableDictionary *) parameters
                      success:(void (^)(NSMutableArray *)) success
                      failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my comment for the file: %@ with parameters: %@", [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File or file id cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:@"comment" forKey:CATEGORY];
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/document/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      file.fileId,
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertCommentListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
    
}

- (void) getFilesInMyRecyclebinWithParameters:(NSMutableDictionary *) parameters
                                      success:(void (^)(NSMutableArray *)) success
                                      failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my files in recycle bin with parameters: %@", [parameters description]] from:self];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      [self convertToStringWithViewType:F_RECYCLE_BIN],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                NSMutableArray *list = [self convertFileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];

}

- (void) updateMetadataForFile:(IBMFileEntry *) file
                    parameters:(NSMutableDictionary *) parameters
                       payload:(NSMutableDictionary *) payload
                       success:(void (^)(IBMFileEntry *)) success
                       failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Updating file: %@ with parameters: %@ payload: %@", [file description], [parameters description], [payload description]] from:self];
    
    if (file == nil || file.fileId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File or file id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/atom+xml", @"Content-Type",
                                    nil];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    NSString *body = [self constructBodyForFile:file withPayloadDict:payload];
    [parameters setValue:body forKey:@"body"];
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/document/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      file.fileId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initPutRequestWithPath:path
                                            headers:headers
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                IBMFileEntry *file = [[IBMFileEntry alloc] initWithXMLDocument:result];
                                                success(file);
                                            } failure:^(id response, NSError *error) {
                                                failure(error);
                                            }];
}

- (void) lockFile:(NSString *) fileId
       parameters:(NSMutableDictionary *) parameters
          success:(void (^)(BOOL)) success
          failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Locking file: %@ with parameters: %@", fileId, [parameters description]] from:self];
    
    if (fileId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"file id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"file id cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [self getNonceWithSuccess:^(NSString *nonce) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"text/plain", @"Content-Type",
                                        nonce, @"X-Update-Nonce",
                                        nil];
        [parameters setValue:@"HARD" forKey:LOCK];
        NSString *path = [NSString stringWithFormat:@"%@/%@/api/document/%@/%@",
                          FILES_URL,
                          [self getAuthType],
                          fileId,
                          [self convertToStringWithResultType:F_LOCK_]];
        [[self getClientService] initPostRequestWithPath:path
                                                 headers:headers
                                              parameters:parameters
                                                  format:RESPONSE_NONE
                                                 success:^(id response, id result) {
                                                     success(YES);
                                                 } failure:^(id response, NSError * error) {
                                                     failure(error);
                                                 }];
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (void) unlockFile:(NSString *) fileId
         parameters:(NSMutableDictionary *) parameters
            success:(void (^)(BOOL)) success
            failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Locking file: %@ with parameters: %@", fileId, [parameters description]] from:self];
    
    if (fileId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"file id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"file id cannot be nil", @"description", nil]]);
        return;
    }
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [self getNonceWithSuccess:^(NSString *nonce) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"text/plain", @"Content-Type",
                                        nonce, @"X-Update-Nonce",
                                        nil];
        [parameters setValue:@"NONE" forKey:LOCK];
        NSString *path = [NSString stringWithFormat:@"%@/%@/api/document/%@/%@",
                          FILES_URL,
                          [self getAuthType],
                          fileId,
                          [self convertToStringWithResultType:F_LOCK_]];
        [[self getClientService] initPostRequestWithPath:path
                                                 headers:headers
                                              parameters:parameters
                                                  format:RESPONSE_NONE
                                                 success:^(id response, id result) {
                                                     //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                     success(YES);
                                                 } failure:^(id response, NSError * error) {
                                                     failure(error);
                                                 }];
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void) addCommentToFile:(IBMFileEntry *) file
               parameters:(NSMutableDictionary *) parameters
                  comment:(NSString *) comment
                  success:(void (^)(IBMFileCommentEntry *)) success
                  failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Adding comment: %@ to a file: %@ with parameters: %@", comment, file.title, [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || file.personEntry.userUuid == nil || comment == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"file, file id, user id or comment cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"file, file id, user id or comment cannot be nil", @"description", nil]]);
        return;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/atom+xml", @"Content-Type",
                                    nil];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    
    NSString *body = [self constructBodyForComment:comment forOperation:@"add"];
    [parameters setValue:body forKey:@"body"];
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/userlibrary/%@/document/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      file.personEntry.userUuid,
                      file.fileId,
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initPostRequestWithPath:path
                                             headers:headers
                                          parameters:parameters
                                              format:RESPONSE_XML
                                             success:^(id response, id result) {
                                                 //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                 IBMFileCommentEntry *comment = [[IBMFileCommentEntry alloc] initWithXMLDocument:result];
                                                 success(comment);
                                             } failure:^(id response, NSError * error) {
                                                 failure(error);
                                             }];
}

- (void) addCommentToMyFile:(IBMFileEntry *) file
                 parameters:(NSMutableDictionary *) parameters
                    comment:(NSString *) comment
                    success:(void (^)(IBMFileCommentEntry *)) success
                    failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Adding comment: %@ to my file: %@ with parameters: %@", comment, file.title, [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || comment == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"file, file id or comment cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"file, file id or comment cannot be nil", @"description", nil]]);
        return;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/atom+xml", @"Content-Type",
                                    nil];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    
    NSString *body = [self constructBodyForComment:comment forOperation:@"add"];
    [parameters setValue:body forKey:@"body"];
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/document/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      file.fileId,
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initPostRequestWithPath:path
                                             headers:headers
                                          parameters:parameters
                                              format:RESPONSE_XML
                                             success:^(id response, id result) {
                                                 //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                 IBMFileCommentEntry *comment = [[IBMFileCommentEntry alloc] initWithXMLDocument:result];
                                                 success(comment);
                                             } failure:^(id response, NSError * error) {
                                                 failure(error);
                                             }];
}

- (void) addFilesToFolder:(NSString *) folderId
                    files:(NSMutableArray *) files
               parameters:(NSMutableDictionary *) parameters
                  success:(void (^)(BOOL)) success
                  failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Adding files: %@ to the folder: %@ with parameters: %@", [files description], folderId, [parameters description]] from:self];
    
    if (folderId == nil || files == nil || [files count] == 0) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"Folder id and files cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Folder if and files cannot be nil", @"description", nil]]);
        return;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/atom+xml", @"Content-Type",
                                    nil];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    
    NSString *body = [self constructBodyForMultipleEntries:files];
    [parameters setValue:body forKey:@"body"];
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/collection/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      folderId,
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initPostRequestWithPath:path
                                             headers:headers
                                          parameters:parameters
                                              format:RESPONSE_NONE
                                             success:^(id response, id result) {
                                                 success(YES);
                                             } failure:^(id response, NSError * error) {
                                                 failure(error);
                                             }];
}

- (void) getCommentWithCommentId:(NSString *) commentId
                         forFile:(IBMFileEntry *) file
                      parameters:(NSMutableDictionary *) parameters
                         success:(void (^)(IBMFileCommentEntry *)) success
                         failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting comment: %@ for the file: %@ with parameters: %@", commentId, [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || file.personEntry.userUuid == nil || commentId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File, file id, user id and comment id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File, file id, user id and comment id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/userlibrary/%@/document/%@/comment/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      file.personEntry.userUuid,
                      file.fileId,
                      commentId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                IBMFileCommentEntry *comment = [[IBMFileCommentEntry alloc] initWithXMLDocument:result];
                                                success(comment);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}


- (void) getMyCommentWithCommentId:(NSString *) commentId
                           forFile:(IBMFileEntry *) file
                        parameters:(NSMutableDictionary *) parameters
                           success:(void (^)(IBMFileCommentEntry *)) success
                           failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting my comment: %@ for the file: %@ with parameters: %@", commentId, [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || commentId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File, file id and comment id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File, file id and comment id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/document/%@/comment/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      file.fileId,
                      commentId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                IBMFileCommentEntry *comment = [[IBMFileCommentEntry alloc] initWithXMLDocument:result];
                                                success(comment);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) deleteCommentForFile:(IBMFileEntry *) file
                    commentId:(NSString *) commentId
                   parameters:(NSMutableDictionary *) parameters
                      success:(void (^)(BOOL)) success
                      failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Deleting comment: %@ for the file: %@ with parameters: %@", commentId, [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || file.personEntry.userUuid == nil || commentId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File, file id, user id and comment id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File, file id, user id and comment id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/userlibrary/%@/document/%@/comment/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      file.personEntry.userUuid,
                      file.fileId,
                      commentId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initDeleteRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_NONE
                                            success:^(id response, id result) {
                                                success(YES);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}


- (void) deleteMyCommentForFile:(IBMFileEntry *) file
                      commentId:(NSString *) commentId
                     parameters:(NSMutableDictionary *) parameters
                        success:(void (^)(BOOL)) success
                        failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Deleting my comment: %@ for the file: %@ with parameters: %@", commentId, [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || commentId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File, file id and comment id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File, file id and comment id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/document/%@/comment/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      file.fileId,
                      commentId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initDeleteRequestWithPath:path
                                            parameters:parameters
                                                format:RESPONSE_NONE
                                               success:^(id response, id result) {
                                                   success(YES);
                                               } failure:^(id response, NSError * error) {
                                                   failure(error);
                                               }];
}


- (void) updateCommentForFile:(IBMFileEntry *) file
                    commentId:(NSString *) commentId
                      comment:(NSString *) comment
                   parameters:(NSMutableDictionary *) parameters
                      success:(void (^)(IBMFileCommentEntry *)) success
                      failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Updating comment: %@ for the file: %@ with parameters: %@", commentId, [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || file.personEntry.userUuid == nil || commentId == nil || comment == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File, file id, user id, comment and comment id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File, file id, user id, comment and comment id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/atom+xml", @"Content-Type",
                                    nil];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    NSString *body = [self constructBodyForComment:comment forOperation:@"update"];
    [parameters setValue:body forKey:@"body"];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/userlibrary/%@/document/%@/comment/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      file.personEntry.userUuid,
                      file.fileId,
                      commentId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initPutRequestWithPath:path
                                            headers:headers
                                            parameters:parameters
                                                format:RESPONSE_XML
                                               success:^(id response, id result) {
                                                   //NSLog(@"%@", [((IBMXMLDocument *) result).rootElement description]);
                                                   IBMFileCommentEntry *comment = [[IBMFileCommentEntry alloc] initWithXMLDocument:result];
                                                   success(comment);
                                               } failure:^(id response, NSError * error) {
                                                   failure(error);
                                               }];
}



- (void) updateMyCommentForFile:(IBMFileEntry *) file
                      commentId:(NSString *) commentId
                        comment:(NSString *) comment
                     parameters:(NSMutableDictionary *) parameters
                        success:(void (^)(IBMFileCommentEntry *)) success
                        failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Updating my comment: %@ for the file: %@ with parameters: %@", commentId, [file description], [parameters description]] from:self];
    
    if (file == nil || file.fileId == nil || file.personEntry.userUuid == nil || commentId == nil || comment == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File, file id, comment and comment id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File, file id, comment and comment id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"application/atom+xml", @"Content-Type",
                                    nil];
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    NSString *body = [self constructBodyForComment:comment forOperation:@"update"];
    [parameters setValue:body forKey:@"body"];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/document/%@/comment/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      file.fileId,
                      commentId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initPutRequestWithPath:path
                                            headers:headers
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                IBMFileCommentEntry *comment = [[IBMFileCommentEntry alloc] initWithXMLDocument:result];
                                                success(comment);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) deleteFileWithFileId:(NSString *) fileId
                   parameters:(NSMutableDictionary *) parameters
                      success:(void (^)(BOOL)) success
                      failure:(void (^)(NSError *)) failure {
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Deleting file: %@ with parameters: %@", fileId, [parameters description]] from:self];
    
    if (fileId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"File id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"File id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/document/%@/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                      fileId,
                      [self convertToStringWithResultType:F_ENTRY]];
    [[self getClientService] initDeleteRequestWithPath:path
                                            parameters:parameters
                                                format:RESPONSE_NONE
                                               success:^(id response, id result) {
                                                   success(YES);
                                               } failure:^(id response, NSError * error) {
                                                   failure(error);
                                               }];
}

- (void) getNonceWithSuccess:(void (^)(NSString *)) success
                     failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Getting nonce value"] from:self];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithResultType:F_NONCE]];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:nil
                                             format:RESPONSE_TEXT
                                            success:^(id response, id result) {
                                                success(result);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) createFolderWithName:(NSString *) folderName
                  description:(NSString *) description
                    shareWith:(NSString *) shareWith
                      success:(void (^)(IBMFileEntry *)) success
                      failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Creating folder %@", folderName] from:self];
    
    if (folderName == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"folder name cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"folder name cannot be nil", @"description", nil]]);
    }
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                    @"application/atom+xml", @"Content-Type",
                                    nil];
    NSString *body = [self constructBodyForFolderName:folderName
                                          description:description
                                            shareWith:shareWith
                                            operation:@"create"
                                             entityId:nil];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       body, @"body",
                                       nil];
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/collections/%@",
                      FILES_URL,
                      [self getAuthType],
                      [self convertToStringWithResultType:F_FEED]];
    [[self getClientService] initPostRequestWithPath:path
                                             headers:headers
                                          parameters:parameters
                                              format:RESPONSE_XML
                                             success:^(id response, id result) {
                                                 IBMFileEntry *entry = [[IBMFileEntry alloc] initWithXMLDocument:result];
                                                 success(entry);
                                             } failure:^(id reponse, NSError *error) {
                                                 failure(error);
                                             }];
}

- (void) deleteFolderWithId:(NSString *) folderId
                    success:(void (^)(BOOL)) success
                    failure:(void (^)(NSError *)) failure {
    
    [FBLog log:[NSString stringWithFormat:@"Deleting folder: %@", folderId] from:self];
    if (folderId == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"Folder id cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Folder id cannot be nil", @"description", nil]]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/api/collection/%@/entry",
                      FILES_URL,
                      [self getAuthType],
                      folderId];
    [[self getClientService] initDeleteRequestWithPath:path
                                            parameters:nil
                                                format:RESPONSE_NONE
                                               success:^(id response, id result) {
                                                   success(YES);
                                               } failure:^(id response, NSError * error) {
                                                   failure(error);
                                               }];
}

- (void) uploadFileWithContent:(id) content
                      fileName:(NSString *) fileName
                      mimeType:(NSString *) mimeType
                       success:(void (^)(IBMFileEntry *)) success
                       failure:(void (^)(NSError *)) failure {
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Uploading file"] from:self];
    
    if (fileName == nil || mimeType == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"fileName or mimeType cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"fileName or mimeType cannot be nil", @"description", nil]]);
        
        return;
    }
    
    [self getNonceWithSuccess:^(NSString *nonce) {
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        nonce, @"X-Update-Nonce",
                                        mimeType, @"Content-Type",
                                        fileName, @"Slug",
                                        nil];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           content, @"body",
                                           nil];
        NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@",
                          FILES_URL,
                          [self getAuthType],
                          [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                          [self convertToStringWithResultType:F_FEED]];
        [[self getClientService] initPostRequestWithPath:path
                                                 headers:headers
                                              parameters:parameters
                                                  format:RESPONSE_XML
                                                 success:^(id response, id result) {
                                                     //NSLog(@"%@", [result description]);
                                                     
                                                     IBMFileEntry *entry = [[IBMFileEntry alloc] initWithXMLDocument:result];
                                                     success(entry);
                                                 } failure:^(id reponse, NSError *error) {
                                                     failure(error);
                                                 }];

    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void) uploadMultiPartFileWithContent:(id) content
                               fileName:(NSString *) fileName
                               mimeType:(NSString *) mimeType
                           fromUserType:(NSString *) user
                              groupType:(NSString *) group
                                appType:(NSString *) app
                                success:(void (^)(id)) success
                                failure:(void (^)(NSError *)) failure {
    
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Uploading multi part file"] from:self];
    
    if (fileName == nil || mimeType == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"fileName or mimeType cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"fileName or mimeType cannot be nil", @"description", nil]]);
        
        return;
    }
    
    [self getNonceWithSuccess:^(NSString *nonce) {
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        nonce, @"X-Update-Nonce",
                                        nil];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           nil];
        NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@/%@",
                          FILES_URL,
                          [self getAuthType],
                          user,
                          group,
                          app];
        [[self getClientService] initMultiPartFileUploadRequestWithPath:path
                                                               fileName:fileName
                                                               mimeType:mimeType
                                                                content:content
                                                                headers:headers
                                                             parameters:parameters
                                                                 format:RESPONSE_XML
                                                                success:^(id response, id result) {
                                                                    NSError *error = nil;
                                                                    NSArray *array = [((IBMXMLDocument *)result) nodesForXPath:@"/html/body" error:&error];
                                                                    GDataXMLNode *node = [array objectAtIndex:0];
                                                                    id processedResult = [NSJSONSerialization JSONObjectWithData:[node.stringValue dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                                                                    success(processedResult);
                                                                } failure:^(id reponse, NSError *error) {
                                                                    failure(error);
                                                                }];
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void) uploadMultiPartFileWithContent:(id) content
                               fileName:(NSString *) fileName
                               mimeType:(NSString *) mimeType
                                success:(void (^)(id)) success
                                failure:(void (^)(NSError *)) failure {
    
    
    if (IS_DEBUGGING_SBTK)
        [FBLog log:[NSString stringWithFormat:@"Uploading multi part file"] from:self];
    
    if (fileName == nil || mimeType == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"fileName or mimeType cannot be nil"] from:self];
        
        failure([NSError errorWithDomain:@"IBMConnectionsFileService"
                                    code:100
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"fileName or mimeType cannot be nil", @"description", nil]]);
        
        return;
    }
    
    [self getNonceWithSuccess:^(NSString *nonce) {
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        nonce, @"X-Update-Nonce",
                                        nil];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           nil];
        NSString *path = [NSString stringWithFormat:@"%@/%@/api/%@/%@",
                          FILES_URL,
                          [self getAuthType],
                          [self convertToStringWithCategoryType:F_MY_USER_LIBRARY],
                          [self convertToStringWithResultType:F_FEED]];
        [[self getClientService] initMultiPartFileUploadRequestWithPath:path
                                                               fileName:fileName
                                                               mimeType:mimeType
                                                                content:content
                                                                headers:headers
                                                             parameters:parameters
                                                                 format:RESPONSE_XML
                                                                success:^(id response, id result) {
                                                                    NSError *error = nil;
                                                                    NSArray *array = [((IBMXMLDocument *)result) nodesForXPath:@"/html/body" error:&error];
                                                                    GDataXMLNode *node = [array objectAtIndex:0];
                                                                    id processedResult = [NSJSONSerialization JSONObjectWithData:[node.stringValue dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                                                                    success(processedResult);
                                                                } failure:^(id reponse, NSError *error) {
                                                                    failure(error);
                                                                }];
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - helper methods

- (NSString *) getAuthType {
    return [self.endPoint getAuthType];
}

- (NSString*) convertToStringWithCategoryType:(F_CATEGORY_TYPE) type {
    NSString *result = nil;
    
    switch(type) {
        case F_MY_FAVORITES:
            result = @"myfavorites";
            break;
        case F_MY_USER_LIBRARY:
            result = @"myuserlibrary";
            break;
        default:
            result = @"myfavorites";
    }
    
    return result;
}

- (NSString*) convertToStringWithResultType:(F_RESULT_TYPE) type {
    NSString *result = nil;
    
    switch(type) {
        case F_FEED:
            result = @"feed";
            break;
        case F_MEDIA:
            result = @"media";
            break;
        case F_ENTRY:
            result = @"entry";
            break;
        case F_REPORTS:
            result = @"reports";
            break;
        case F_NONCE:
            result = @"nonce";
            break;
        case F_LOCK_:
            result = @"lock";
            break;
        case F_NULL:
            result = @"";
            break;
        default:
            result = @"feed";
    }
    
    return result;
}

- (NSString*) convertToStringWithViewType:(F_VIEW_TYPE) type {
    NSString *result = nil;
    
    switch(type) {
        case F_FILES:
            result = @"documents";
            break;
        case F_FOLDERS:
            result = @"collections";
            break;
        case F_RECYCLE_BIN:
            result = @"view/recyclebin";
            break;
        default:
            result = @"documents";
    }
    
    return result;
}

- (NSString*) convertToStringWithFilterType:(F_FILTER_TYPE) type {
    NSString *result = nil;
    
    switch(type) {
        case F_ADDEDTO:
            result = @"addedto";
            break;
        case F_SHARE:
            result = @"share";
            break;
        case F_SHARED:
            result = @"shared";
            break;
        case F_MY_SHARES:
            result = @"myshares";
            break;
        case F_COMMENT:
            result = @"comment";
            break;
        case F_NULL_FILTER:
            result = @"";
            break;
        default:
            result = @"share";
    }
    
    return result;
}

- (NSMutableArray *) convertFileListWithXML:(IBMXMLDocument *) document {
    
    NSMutableArray *listOfFiles = nil;
    if (document != nil) {
        NSError *error;
        NSDictionary *dict = [IBMFileEntry namespacesForFileEntry];
        NSArray *entryList = [document nodesForXPath:@"/a:feed/a:entry" namespaces:dict error:&error];
        if (entryList != nil && [entryList count] > 0) {
            
            listOfFiles = [[NSMutableArray alloc] init];
            for (GDataXMLElement *element in entryList) {
                element.namespaces = document.rootElement.namespaces;
                // Make it a xml document
                IBMXMLDocument *doc = [[IBMXMLDocument alloc] initWithRootElement:element];
                // Create a profile object and add it to the array
                IBMFileEntry *f = [[IBMFileEntry alloc] initWithXMLDocument:doc];
                [listOfFiles addObject:f];
            }
        }
    }
    
    return listOfFiles;
}

- (NSMutableArray *) convertCommentListWithXML:(IBMXMLDocument *) document {
    
    NSMutableArray *listOfFiles = nil;
    if (document != nil) {
        NSError *error;
        NSDictionary *dict = [IBMFileEntry namespacesForFileEntry];
        NSArray *entryList = [document nodesForXPath:@"/a:feed/a:entry" namespaces:dict error:&error];
        if (entryList != nil && [entryList count] > 0) {
            
            listOfFiles = [[NSMutableArray alloc] init];
            for (GDataXMLElement *element in entryList) {
                element.namespaces = document.rootElement.namespaces;
                // Make it a xml document
                IBMXMLDocument *doc = [[IBMXMLDocument alloc] initWithRootElement:element];
                // Create a profile object and add it to the array
                IBMFileCommentEntry *c = [[IBMFileCommentEntry alloc] initWithXMLDocument:doc];
                [listOfFiles addObject:c];
            }
        }
    }
    
    return listOfFiles;
}

- (NSString *) constructBodyForFolderName:(NSString *) folderName description:(NSString *) description shareWith:(NSString *) shareWith operation:(NSString *) operation entityId:(NSString *) entityId {
    
    NSString *visibility = @"null", *shareWithId = @"null", *shareWithWhat = @"null", *shareWithRole = @"null";
    NSString *payload = @"";
    payload = [payload stringByAppendingString:@"<entry xmlns=\"http://www.w3.org/2005/Atom\">"];
    payload = [payload stringByAppendingFormat:@"<category term=\"collection\"  label=\"collection\" scheme=\"tag:ibm.com,2006:td/type\"/>"];
    if (operation != nil && ![operation isEqualToString:@""]) {
        if ([operation isEqualToString:@"update"]) {
            payload = [payload stringByAppendingString:[NSString stringWithFormat:@"<id>%@</id>", entityId]];
        }
        
        payload = [payload stringByAppendingFormat:@"<label xmlns=\"urn:ibm.com/td\" makeUnique=\"true\">%@</label>", folderName];
        payload = [payload stringByAppendingFormat:@"<title>%@</title>", folderName];
        if (description != nil && ![description isEqualToString:@""]) {
            payload = [payload stringByAppendingFormat:@"<summary type=\"text\">%@</summary>", description];
        }
        if (shareWith == nil || [shareWith isEqualToString:@""]) {
            visibility = @"private";
            shareWith = @"";
        } else {
            visibility = @"public";
            NSArray *parts = [shareWith componentsSeparatedByString:@","];
            if ([parts count] == 3) {
                shareWithId = [parts objectAtIndex:0];
                shareWithWhat = [parts objectAtIndex:1];
                shareWithRole = [parts objectAtIndex:2];
            } else {
                if (IS_DEBUGGING_SBTK)
                    [FBLog log:@"There should exactly 3 parts" from:self];
                return nil;
            }
            
            shareWith = [NSString stringWithFormat:@"<member ca:id=\"%@\" xmlns=\"http://www.ibm.com/xmlns/prod/composite-applications/v1.0\" ca:type=\"%@\" xmlns:ca=\"http://www.ibm.com/xmlns/prod/composite-applications/v1.0\" ca:role=\"%@\"></member>", shareWithId, shareWithWhat, shareWithRole];
        }
        payload = [payload stringByAppendingFormat:@"<visibility xmlns=\"urn:ibm.com/td\">%@</visibility> <sharedWith xmlns=\"urn:ibm.com/td\">%@</sharedWith>", visibility, shareWith];
    }
    
    
    payload = [payload stringByAppendingString:@"</entry>"];
    
    return payload;
    
}

- (NSString *) constructBodyForFile:(IBMFileEntry *) file withPayloadDict:(NSMutableDictionary *) payloadDict {
    
    if (payloadDict == nil)
        return nil;
    
    NSString *payload = @"";
    payload = [payload stringByAppendingString:@"<entry xmlns=\"http://www.w3.org/2005/Atom\"><category term=\"document\" label=\"document\" scheme=\"tag:ibm.com,2006:td/type\"></category>"];
    payload = [payload stringByAppendingFormat:@"<id>urn:lsid:ibm.com:td:%@</id>", file.fileId];
    
    for (NSString *key in payloadDict) {
        NSString *value = [payloadDict valueForKey:key];
        if (key != nil && value != nil && ![key isEqualToString:@""]) {
            if ([key isEqualToString:@"label"]) {
                payload = [payload stringByAppendingFormat:@"<label xmlns=\"%@\">%@</label>", @"urn:ibm.com/td", value];
                payload = [payload stringByAppendingFormat:@"<title>%@</title>", value];
            } else if ([key isEqualToString:@"summary"]) {
                payload = [payload stringByAppendingFormat:@"<summary type=\"text\">%@</summary>", value];
            } else if ([key isEqualToString:@"visibility"]) {
                payload = [payload stringByAppendingFormat:@"<visibility xmlns=\"%@\">%@</visibility>", @"urn:ibm.com/td", value];
            }
        }
    }
    
    payload = [payload stringByAppendingString:@"</entry>"];
    
    return payload;
    
}

- (NSString *) constructBodyForComment:(NSString *) comment forOperation:(NSString *) operation {
    
    if (comment == nil)
        return nil;
    
    NSString *payload = @"";
    payload = [payload stringByAppendingString:@"<entry xmlns=\"http://www.w3.org/2005/Atom\"><category term=\"comment\"  label=\"comment\" scheme=\"tag:ibm.com,2006:td/type\"/>"];
    
    if (operation != nil && ![operation isEqualToString:@""] && [operation isEqualToString:@"delete"]) {
        payload = [payload stringByAppendingFormat:@"<deleteWithRecord xmlns=\"%@\">false</deleteWithRecord>", @"urn:ibm.com/td"];
    } else {
        payload = [payload stringByAppendingFormat:@"<content type=\"text/plain\">%@</content>", comment];
    }
    
    payload = [payload stringByAppendingString:@"</entry>"];
    
    return payload;
}

- (NSString *) constructBodyForMultipleEntries:(NSMutableArray *) list {
    
    if (list == nil || [list count] == 0)
        return nil;
    
    NSString *payload = @"";
    payload = [payload stringByAppendingString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><feed xmlns=\"http://www.w3.org/2005/Atom\">"];
    
    NSString *multipleEntryId = @"itemId";
    for (IBMFileEntry *file in list) {
        payload = [payload stringByAppendingFormat:@"<entry><%@ xmlns=\"urn:ibm.com/td\">%@</%@></entry>", multipleEntryId, file.fileId, multipleEntryId];
    }
    
    payload = [payload stringByAppendingString:@"</feed>"];
    
    return payload;
}

@end
