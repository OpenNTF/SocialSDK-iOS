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

//  This class is a unit test class for Connections' File Service
//  A test file is created at the beginning and deleted at the end of the test cases

#import "IBMConnectionsFileServiceTest.h"
#import "IBMUtilsTest.h"
#import "IBMConstantsTest.h"
#import "IBMConnectionsFileService.h"

@implementation IBMConnectionsFileServiceTest

IBMFileEntry *testFile;
IBMFileCommentEntry *testComment;
NSString *fileId = @"";
NSString *folderId = @"";

/**
 Here we're creating a file with comment and folder later at the end of the test
 we will delete this
 */
+ (void)setUp
{
    [super setUp];
    
    // Set up credentials for authentication
    [IBMUtilsTest setCredentials];
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        
        NSString *content = @"This is the test content of the file";
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"public", @"visibility",
                                    nil];
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS uploadFileWithContent:content fileName:TEST_FILE_NAME mimeType:@"text/plain" success:^(IBMFileEntry *file) {
            testFile = file;
            fileId = file.fileId;
            IBMConnectionsFileService *fS_ = [[IBMConnectionsFileService alloc] init];
            [fS_ addCommentToMyFile:file parameters:parameters comment:TEST_FILE_COMMENT success:^(IBMFileCommentEntry *comment) {
                testComment = comment;
                // Now add a folder
                IBMConnectionsFileService *fS__ = [[IBMConnectionsFileService alloc] init];
                [fS__ createFolderWithName:TEST_FODLER_NAME description:@"Test folder" shareWith:nil success:^(IBMFileEntry *folder) {
                    folderId = folder.fileId;
                    // Now add file to the folder
                    IBMConnectionsFileService *fS___ = [[IBMConnectionsFileService alloc] init];
                    NSMutableArray *files = [NSMutableArray arrayWithObject:file];
                    [fS___ addFilesToFolder:folderId files:files parameters:nil success:^(BOOL success) {
                        completionBlock();
                    } failure:^(NSError *error) {
                        [NSException raise:@"File Test SetUp Failed" format:@"Adding file to the folder is failed at the SETUP in IBMConnectionsFileServiceTest"];
                        completionBlock();
                    }];
                } failure:^(NSError *error) {
                    [NSException raise:@"File Test SetUp Failed" format:@"Folder creation is failed at the SETUP in IBMConnectionsFileServiceTest"];
                    completionBlock();
                }];
            } failure:^(NSError *error) {
                [NSException raise:@"File Test SetUp Failed" format:@"File comment creation is failed at the SETUP in IBMConnectionsFileServiceTest"];
                completionBlock();
            }];
        } failure:^(NSError *error) {
            [NSException raise:@"File Test SetUp Failed" format:@"File creation is failed at the SETUP in IBMConnectionsFileServiceTest"];
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

+ (void)tearDown
{
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS deleteFileWithFileId:fileId parameters:nil success:^(BOOL success) {
            // Now delete the folder
            IBMConnectionsFileService *fS_ = [[IBMConnectionsFileService alloc] init];
            [fS_ deleteFolderWithId:folderId success:^(BOOL success) {
                completionBlock();
            } failure:^(NSError *error) {
                [NSException raise:@"File Test TearDown Failed" format:@"Folder deletion is failed at the TEARDOWN in IBMConnectionsFileServiceTest"];
                completionBlock();
            }];
        } failure:^(NSError *error) {
            [NSException raise:@"File Test TearDown Failed" format:@"File deletion is failed at the TEARDOWN in IBMConnectionsFileServiceTest"];
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
    
    [super tearDown];
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

/**
 Test to get my files
 @pre: none
 @post: id of returned entries should not be nil
 */
- (void) testGetMyFiles {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getMyFilesWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *file in list) {
                STAssertNotNil(file.fileId, @"File id is nil");
                STAssertEqualObjects(file.category, @"document", @"File category is not a 'document'");
                STAssertEqualObjects(file.personEntry.userUuid, TEST_ACCOUNT_USERID, @"This file is not created by me although it should");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get my comments of a file
 @pre: testFile needs to set correctly at the setUp
 @post: comment should be equal to the comment entered at setUp
 */
- (void) testGetMyCommentsForFile {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getMyCommentsForFile:testFile withParameters:nil success:^(NSMutableArray *list) {
            STAssertNotNil(list, @"List is nil");
            if ([list count] != 1)
                STFail(@"File has more than one comment");
            IBMFileCommentEntry *c = [list objectAtIndex:0];
            STAssertEqualObjects(c.comment, TEST_FILE_COMMENT, @"Returned comment is not what we're looking for");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get file shared with me
 @pre: none
 @post: id of returned entries should not be nil
 */
- (void) testGetFilesSharedWithMe {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getFilesSharedWithMeWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *file in list) {
                STAssertNotNil(file.fileId, @"File id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get files shared by me
 @pre: none
 @post: id of returned entries should not be nil
 */
- (void) testGetFilesSharedByMe {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getFilesSharedByMeWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *file in list) {
                STAssertNotNil(file.fileId, @"File id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get public files
 @pre: none
 @post: id of returned entries should not be nil and the visibility should be public
 */
- (void) testGetPublicFiles {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getPublicFilesWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *file in list) {
                STAssertNotNil(file.fileId, @"File id is nil");
                STAssertEqualObjects(file.visibility, @"public", @"File is not public");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get pinned files
 @pre: none
 @post: id of returned entries should not be nil and the visibility should be public
 */
- (void) testGetPinnedFiles {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getPinnedFilesWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *file in list) {
                STAssertNotNil(file.fileId, @"File id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to create and delete folder
 @pre: created folder should be success
 @post: request should end with success
 */
- (void) testCreateAndDeleteFolder {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS createFolderWithName:@"iOSTestFolder" description:@"Folder to test..." shareWith:nil success:^(IBMFileEntry *file) {
            STAssertNotNil(file.fileId, @"File id is nil");
            
            IBMConnectionsFileService *fS_ = [[IBMConnectionsFileService alloc] init];
            [fS_ deleteFolderWithId:file.fileId success:^(BOOL success) {
                completionBlock();
            } failure:^(NSError *error) {
                STFail([error description]);
                completionBlock();
            }];
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get my folders
 @pre: none
 @post: folder id should not be nil
 */
- (void) testGetMyFolders {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getMyFoldersWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *file in list) {
                STAssertNotNil(file.fileId, @"Folder id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get my pinned folders
 @pre: none
 @post: folder id should not be nil
 */
- (void) testGetMyPinnedFolders {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getMyPinnedFoldersWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *file in list) {
                STAssertNotNil(file.fileId, @"Folder id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get my folders which has recently added files
 @pre: none
 @post: folder id should not be nil
 */
- (void) testgetFoldersWithRecentlyAddedFiles {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getFoldersWithRecentlyAddedFilesWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *file in list) {
                STAssertNotNil(file.fileId, @"Folder id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get my files in the test folder
 @pre: setUp should result with success
 @post: file should be the one we created earlier
 */
- (void) testGetFilesInFolder {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getFilesInFolderWithCollectionId:folderId parameters:nil success:^(NSMutableArray *list) {
            STAssertNotNil(list, @"list is nil");
            if ([list count] != 1)
                STFail(@"Number of files should be 1, no more no less");
            IBMFileEntry *f = [list objectAtIndex:0];
            STAssertNotNil(f.fileId, @"File id is nil");
            STAssertEqualObjects(f.title, TEST_FILE_NAME, @"File names are not equal");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get public folders
 @pre: none
 @post: returned folder id should not be nil
 */
- (void) testGetPublicFolders {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getPublicFileFoldersWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *f in list) {
                STAssertNotNil(f.fileId, @"Folder id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get person library
 @pre: none
 @post: returned file id should not be nil
 */
- (void) testGetPersonLibrary {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getPersonLibraryWithUserId:TEST_ACCOUNT_USERID parameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *f in list) {
                STAssertNotNil(f.fileId, @"File id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get comments for file
 @pre: none
 @post: returned comment should be the one we created
 */
- (void) testGetCommentsForFile {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getCommentsForFile:testFile withParameters:nil success:^(NSMutableArray *list) {
            STAssertNotNil(list, @"List is nil");
            if ([list count] != 1)
                STFail(@"There should only be one comment");
            IBMFileCommentEntry *c = [list objectAtIndex:0];
            STAssertEqualObjects(c.comment, TEST_FILE_COMMENT, @"Comments are not equal");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}


/**
 Test to get files in my recycle bin
 @pre: none
 @post: File id should not be nil
 */
- (void) testGetFilesInMyRecyclebin {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getFilesInMyRecyclebinWithParameters:nil success:^(NSMutableArray *list) {
            for (IBMFileEntry *f in list) {
                STAssertNotNil(f.fileId, @"File id is nil");
            }
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get file with fileId
 @pre: none
 @post: returned file should be same one
 */
- (void) testGetFileWithFileId {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getFileWithFileId:testFile.fileId parameters:nil success:^(IBMFileEntry *file) {
            STAssertNotNil(file.fileId, @"File id is nil");
            STAssertEqualObjects(file.fileId, testFile.fileId, @"File ids' are different");
            STAssertEqualObjects(file.title, testFile.title, @"File titles' are different");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to update the metadata of the file
 @pre: none
 @post: returned file should include the new label
 */
- (void) testUpdateMetadataForFile {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        NSMutableDictionary *payloadDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"2013-07-16T21:33:54.826Z", @"summary", nil];
        [fS updateMetadataForFile:testFile parameters:nil payload:payloadDict success:^(IBMFileEntry *f) {
            STAssertNotNil(f.fileId, @"File id is nil");
            STAssertEqualObjects(f.summary, @"2013-07-16T21:33:54.826Z", @"Summaries are different");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];

    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to lock and unlock a file
 @pre: none
 @post: request should result with success
 */
- (void) testLockAndUnlockFile {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS lockFile:testFile.fileId parameters:nil success:^(BOOL success) {
            // Now unlock the file
            IBMConnectionsFileService *fS_ = [[IBMConnectionsFileService alloc] init];
            [fS_ unlockFile:testFile.fileId parameters:nil success:^(BOOL success) {
                completionBlock();
            } failure:^(NSError *error) {
                STFail([error description]);
                completionBlock();
            }];
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];  
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get comment for file with commentId
 @pre: none
 @post: returned comment should be the same one
 */
- (void) testGetCommentWithCommentId {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getCommentWithCommentId:testComment.commentId forFile:testFile parameters:nil success:^(IBMFileCommentEntry *entry) {
            STAssertNotNil(entry.commentId, @"Comment id is nil");
            STAssertEqualObjects(entry.commentId, testComment.commentId, @"Comment ids are different");
            STAssertEqualObjects(entry.comment, testComment.comment, @"Comment are different");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get my comment for file with commentId
 @pre: none
 @post: returned comment should be the same one
 */
- (void) testGetMyCommentWithCommentId {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getMyCommentWithCommentId:testComment.commentId forFile:testFile parameters:nil success:^(IBMFileCommentEntry *entry) {
            STAssertNotNil(entry.commentId, @"Comment id is nil");
            STAssertEqualObjects(entry.commentId, testComment.commentId, @"Comment ids are different");
            STAssertEqualObjects(entry.comment, testComment.comment, @"Comment are different");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to add, update and delete comment from file
 @pre: none
 @post: request should end with success
 */
- (void) testAddUpdateAndDeleteCommentFromFile {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        NSString *comment = @"Here is a victim comment...";
        [fS addCommentToFile:testFile parameters:nil comment:comment success:^(IBMFileCommentEntry *comment) {
            STAssertNotNil(comment.commentId, @"Comment id is nil");
            IBMConnectionsFileService *fS_ = [[IBMConnectionsFileService alloc] init];
            NSString *newComment = @"update to comment";
            [fS_ updateCommentForFile:testFile commentId:comment.commentId comment:newComment parameters:nil success:^(IBMFileCommentEntry *entry) {
                STAssertNotNil(entry.commentId, @"Comment id is nil");
                STAssertEqualObjects(entry.comment, newComment, @"Comments are not equal");
                IBMConnectionsFileService *fS__ = [[IBMConnectionsFileService alloc] init];
                [fS__ deleteCommentForFile:testFile commentId:comment.commentId parameters:nil success:^(BOOL success) {
                    completionBlock();
                } failure:^(NSError *error) {
                    STFail([error description]);
                    completionBlock();
                }];
            } failure:^(NSError *error) {
                STFail([error description]);
                completionBlock();
            }];
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to add, update and delete my comment from file
 @pre: none
 @post: request should end with success
 */
- (void) testAddUpdateAndDeleteMyCommentFromFile {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        NSString *comment = @"Here is a victim comment...";
        [fS addCommentToFile:testFile parameters:nil comment:comment success:^(IBMFileCommentEntry *comment) {
            STAssertNotNil(comment.commentId, @"Comment id is nil");
            IBMConnectionsFileService *fS_ = [[IBMConnectionsFileService alloc] init];
            NSString *newComment = @"update to comment";
            [fS_ updateMyCommentForFile:testFile commentId:comment.commentId comment:newComment parameters:nil success:^(IBMFileCommentEntry *entry) {
                STAssertNotNil(entry.commentId, @"Comment id is nil");
                STAssertEqualObjects(entry.comment, newComment, @"Comments are not equal");
                IBMConnectionsFileService *fS__ = [[IBMConnectionsFileService alloc] init];
                [fS__ deleteMyCommentForFile:testFile commentId:comment.commentId parameters:nil success:^(BOOL success) {
                    completionBlock();
                } failure:^(NSError *error) {
                    STFail([error description]);
                    completionBlock();
                }];
            } failure:^(NSError *error) {
                STFail([error description]);
                completionBlock();
            }];
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

/**
 Test to get nonce
 @pre: none
 @post: nonce should not be nil
 */
- (void) testGetNonce {
    
    void (^testBlock)(void (^completionBlock)(void)) = ^(void (^completionBlock)(void)) {
        IBMConnectionsFileService *fS = [[IBMConnectionsFileService alloc] init];
        [fS getNonceWithSuccess:^(NSString *nonce) {
            STAssertNotNil(nonce, @"Nonce is nil");
            completionBlock();
        } failure:^(NSError *error) {
            STFail([error description]);
            completionBlock();
        }];
    };
    
    [IBMUtilsTest executeAsyncBlock:testBlock];
}

@end

