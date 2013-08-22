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
#import "IBMFileEntry.h"
#import "IBMFileRequestParameters.h"

@interface IBMConnectionsFileService : IBMBaseService


#pragma mark - properties


#pragma mark - methods

- (id) init;
- (id) initWithEndPointName:(NSString *)endPointName;


/**
 Get file with file id
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getFileWithFileId:(NSString *) fileId
                parameters:(NSMutableDictionary *) parameters
                   success:(void (^)(IBMFileEntry *)) success
                   failure:(void (^)(NSError *)) failure;

/**
 Get my files
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getMyFilesWithParameters:(NSMutableDictionary *) parameters
                          success:(void (^)(NSMutableArray *)) success
                          failure:(void (^)(NSError *)) failure;

/**
 Get files share with me
 @param parameters: to be used when contructing the url
 @param success: block to return activity stream list
 @param failure: block to return error details
 */
- (void) getFilesSharedWithMeWithParameters:(NSMutableDictionary *) parameters
                                   success:(void (^)(NSMutableArray *)) success
                                   failure:(void (^)(NSError *)) failure;

/**
 Get files shared by me
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getFilesSharedByMeWithParameters:(NSMutableDictionary *) parameters
                                   success:(void (^)(NSMutableArray *)) success
                                   failure:(void (^)(NSError *)) failure;

/**
 Get public files
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getPublicFilesWithParameters:(NSMutableDictionary *) parameters
                                 success:(void (^)(NSMutableArray *)) success
                                 failure:(void (^)(NSError *)) failure;

/**
 Get pinned files
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getPinnedFilesWithParameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure;

/**
 Get my folders
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getMyFoldersWithParameters:(NSMutableDictionary *) parameters
                              success:(void (^)(NSMutableArray *)) success
                              failure:(void (^)(NSError *)) failure;

/**
 Get my pinned folders
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getMyPinnedFoldersWithParameters:(NSMutableDictionary *) parameters
                            success:(void (^)(NSMutableArray *)) success
                            failure:(void (^)(NSError *)) failure;

/**
 Get folders with recently added file
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getFoldersWithRecentlyAddedFilesWithParameters:(NSMutableDictionary *) parameters
                                                success:(void (^)(NSMutableArray *)) success
                                                failure:(void (^)(NSError *)) failure;

/**
 Get files in folder
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getFilesInFolderWithCollectionId:(NSString *) collectionId
                               parameters:(NSMutableDictionary *) parameters
                                  success:(void (^)(NSMutableArray *)) success
                                  failure:(void (^)(NSError *)) failure;

/**
 Get public file folders
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getPublicFileFoldersWithParameters:(NSMutableDictionary *) parameters
                                    success:(void (^)(NSMutableArray *)) success
                                    failure:(void (^)(NSError *)) failure;


/**
 Get person library
 @param userId: id of user whose library is retrieved
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getPersonLibraryWithUserId:(NSString *) userId
                       parameters:(NSMutableDictionary *) parameters
                          success:(void (^)(NSMutableArray *)) success
                          failure:(void (^)(NSError *)) failure;


/**
 Get public file comments for a given file entry
 @param file: File in which comments are retrieved for
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getCommentsForPublicFile:(IBMFileEntry *) file
               withParameters:(NSMutableDictionary *) parameters
                      success:(void (^)(NSMutableArray *)) success
                      failure:(void (^)(NSError *)) failure;

/**
 Get comments for a given file entry
 @param file: File in which comments are retrieved for
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getCommentsForFile:(IBMFileEntry *) file
             withParameters:(NSMutableDictionary *) parameters
                    success:(void (^)(NSMutableArray *)) success
                    failure:(void (^)(NSError *)) failure;

/**
 Get comments for a file of mine
 @param file: File in which comments are retrieved for
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getMyCommentsForFile:(IBMFileEntry *) file
               withParameters:(NSMutableDictionary *) parameters
                      success:(void (^)(NSMutableArray *)) success
                      failure:(void (^)(NSError *)) failure;

/**
 Get files in my recycle bin
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getFilesInMyRecyclebinWithParameters:(NSMutableDictionary *) parameters
                                      success:(void (^)(NSMutableArray *)) success
                                      failure:(void (^)(NSError *)) failure;


/**
 Update metadata of a file with a given payload
 @param file: File to be updated
 @param parameters: to be used when contructing the url
 @param payload: payload consisting of metada to be updated
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) updateMetadataForFile:(IBMFileEntry *) file
                    parameters:(NSMutableDictionary *) parameters
                       payload:(NSMutableDictionary *) payload
                       success:(void (^)(IBMFileEntry *)) success
                       failure:(void (^)(NSError *)) failure;


/**
 Lock the given file
 @param fileId: Id of the file to be locked
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) lockFile:(NSString *) fileId
       parameters:(NSMutableDictionary *) parameters
          success:(void (^)(BOOL)) success
          failure:(void (^)(NSError *)) failure;

/**
 Unlock the given file
 @param fileId: Id of the file to be unlocked
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) unlockFile:(NSString *) fileId
         parameters:(NSMutableDictionary *) parameters
            success:(void (^)(BOOL)) success
            failure:(void (^)(NSError *)) failure;

/**
 Add comment to the given file
 @param file: File to be updated
 @param parameters: to be used when contructing the url
 @param comment: comment to be added
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) addCommentToFile:(IBMFileEntry *) file
                    parameters:(NSMutableDictionary *) parameters
                       comment:(NSString *) comment
                       success:(void (^)(IBMFileCommentEntry *)) success
                       failure:(void (^)(NSError *)) failure;

/**
 Add comment to my file
 @param file: File to be updated
 @param parameters: to be used when contructing the url
 @param comment: comment to be added
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) addCommentToMyFile:(IBMFileEntry *) file
                 parameters:(NSMutableDictionary *) parameters
                    comment:(NSString *) comment
                    success:(void (^)(IBMFileCommentEntry *)) success
                    failure:(void (^)(NSError *)) failure;

/**
 Add given files to the given folder
 @param folderId: id of the folder
 @param files: array of files to be added
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) addFilesToFolder:(NSString *) folderId
                    files:(NSMutableArray *) files
               parameters:(NSMutableDictionary *) parameters
                  success:(void (^)(BOOL)) success
                  failure:(void (^)(NSError *)) failure;


/**
 Get comment for a given comment id and file entry
 @param commentId: id of the comment to be retrieved
 @param file: File in which comment is retrieved for
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getCommentWithCommentId:(NSString *) commentId
                         forFile:(IBMFileEntry *) file
                      parameters:(NSMutableDictionary *) parameters
                         success:(void (^)(IBMFileCommentEntry *)) success
                         failure:(void (^)(NSError *)) failure;

/**
 Get my comment for a given comment id and file entry
 @param commentId: id of the comment to be retrieved
 @param file: File in which comment is retrieved for
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getMyCommentWithCommentId:(NSString *) commentId
                           forFile:(IBMFileEntry *) file
                        parameters:(NSMutableDictionary *) parameters
                           success:(void (^)(IBMFileCommentEntry *)) success
                           failure:(void (^)(NSError *)) failure;

/**
 Delete comment for a given file and comment id
 @param file: File whose comment to be deleted
 @param commentId: id of the comment
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) deleteCommentForFile:(IBMFileEntry *) file
                    commentId:(NSString *) commentId
                   parameters:(NSMutableDictionary *) parameters
                      success:(void (^)(BOOL)) success
                      failure:(void (^)(NSError *)) failure;

/**
 Delete my comment for a given file and comment id
 @param file: File whose comment to be deleted
 @param commentId: id of the comment
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) deleteMyCommentForFile:(IBMFileEntry *) file
                    commentId:(NSString *) commentId
                   parameters:(NSMutableDictionary *) parameters
                      success:(void (^)(BOOL)) success
                      failure:(void (^)(NSError *)) failure;

/**
 Update a comment for a given file, comment id and comment
 @param file: File whose comment to be deleted
 @param commentId: id of the comment
 @param comment: text to be updated
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) updateCommentForFile:(IBMFileEntry *) file
                    commentId:(NSString *) commentId
                      comment:(NSString *) comment
                   parameters:(NSMutableDictionary *) parameters
                      success:(void (^)(IBMFileCommentEntry *)) success
                      failure:(void (^)(NSError *)) failure;


/**
 Update my comment for a given file, comment id and comment
 @param file: File whose comment to be deleted
 @param commentId: id of the comment
 @param comment: text to be updated
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) updateMyCommentForFile:(IBMFileEntry *) file
                      commentId:(NSString *) commentId
                        comment:(NSString *) comment
                     parameters:(NSMutableDictionary *) parameters
                        success:(void (^)(IBMFileCommentEntry *)) success
                        failure:(void (^)(NSError *)) failure;

/**
 Delete file with file id
 @param fileId: id of the file
 @param parameters: to be used when contructing the url
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) deleteFileWithFileId:(NSString *) fileId
                   parameters:(NSMutableDictionary *) parameters
                      success:(void (^)(BOOL)) success
                      failure:(void (^)(NSError *)) failure;

/**
 Get nonce value
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) getNonceWithSuccess:(void (^)(NSString *)) success
                     failure:(void (^)(NSError *)) failure;

/**
 Create a folder
 @param folderName: name of the folder
 @param description: description
 @param shareWith: shareWith, comma separated values
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) createFolderWithName:(NSString *) folderName
                  description:(NSString *) description
                    shareWith:(NSString *) shareWith
                      success:(void (^)(IBMFileEntry *)) success
                      failure:(void (^)(NSError *)) failure;


/**
 Delete a folder
 @param folderId: id of the folder
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) deleteFolderWithId:(NSString *) folderId
                    success:(void (^)(BOOL)) success
                    failure:(void (^)(NSError *)) failure;
/**
 Upload file with content
 @param content: file content as NSData or NSString
 @param fileName: name of the file
 @param mimeType: type of the file such as application/pdf
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) uploadFileWithContent:(id) content
                      fileName:(NSString *) fileName
                      mimeType:(NSString *) mimeType
                       success:(void (^)(IBMFileEntry *)) success
                       failure:(void (^)(NSError *)) failure;

/**
 Upload multi part file with content
 @param content: file content as NSData or NSString
 @param fileName: name of the file
 @param mimeType: type of the file such as application/pdf
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) uploadMultiPartFileWithContent:(id) content
                               fileName:(NSString *) fileName
                               mimeType:(NSString *) mimeType
                                success:(void (^)(id)) success
                                failure:(void (^)(NSError *)) failure;

/**
 Upload multi part file with content
 @param content: file content as NSData or NSString
 @param fileName: name of the file
 @param mimeType: type of the file such as application/pdf
 @param user: user
 @param group: group
 @param app: app
 @param success: block to return list
 @param failure: block to return error details
 */
- (void) uploadMultiPartFileWithContent:(id) content
                               fileName:(NSString *) fileName
                               mimeType:(NSString *) mimeType
                           fromUserType:(NSString *) user
                              groupType:(NSString *) group
                                appType:(NSString *) app
                                success:(void (^)(id)) success
                                failure:(void (^)(NSError *)) failure;
@end
