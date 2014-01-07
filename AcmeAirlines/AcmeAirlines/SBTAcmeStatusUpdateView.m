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

//  This class shows an update along with its comments. It also allows user to like and comment on a post

#import "SBTAcmeStatusUpdateView.h"
#import <QuartzCore/QuartzCore.h>
#import "IBMAcmeConstant.h"
#import "SBTAcmeUtils.h"
#import "LikeButton.h"
#import "IBMCommunityMember.h"
#import "ComposeUpdate.h"
#import "SBTAcmeCommunityView.h"
#import "SBTAcmeLargeImageView.h"
#import "SBTProfileListView.h"
#import "FBLog.h"
#import "IBMConnectionsBasicEndPoint.h"

@interface SBTAcmeStatusUpdateView ()

@property (strong, nonatomic) UIBarButtonItem *addLikePostItem;

@end

@implementation SBTAcmeStatusUpdateView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.addLikePostItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewLikePost)];
    self.navigationItem.rightBarButtonItem = self.addLikePostItem;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(findVisibleCellsAndUpdate) withObject:nil afterDelay:0.2];
}

- (void) findVisibleCellsAndUpdate {
    NSArray* visibleCells = [self.tableView indexPathsForVisibleRows];
    [self performSelectorOnMainThread:@selector(rotate:) withObject:visibleCells waitUntilDone:NO];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void) rotate:(NSArray *) visibleCells {
    
    [self.tableView reloadRowsAtIndexPaths:visibleCells withRowAnimation:UITableViewRowAnimationFade];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSArray* visibleCells = [self.tableView indexPathsForVisibleRows];
    [self.tableView reloadRowsAtIndexPaths:visibleCells withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1 + [self.entry.replies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IBMActivityStreamEntry *entry;
    if (indexPath.row == 0) {
        entry = self.entry;
    } else {
        entry = [self.entry.replies objectAtIndex:(indexPath.row-1)];
    }
    
    if ([entry.objectType isEqualToString:@"comment"])
        return [SBTAcmeUtils getCommentCellForEntry:entry tableView:tableView atIndexPath:indexPath viewController:self];
    else
        return [SBTAcmeUtils getStatusUpdateCellForEntry:entry tableView:tableView atIndexPath:indexPath viewController:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IBMActivityStreamEntry *entry;
    if (indexPath.row == 0) {
        entry = self.entry;
    } else {
        entry = [self.entry.replies objectAtIndex:(indexPath.row - 1)];
    }
    
    if ([entry.objectType isEqualToString:@"comment"])
        return [SBTAcmeUtils getHeightForCommentCell:entry];
    else
        return [SBTAcmeUtils getHeightForStatusUpdateCell:entry];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if ([SBTAcmeUtils hasImage:self.entry] == YES) {
            IBMActivityStreamAttachment *attachment = [self.entry.attachments objectAtIndex:0];
            SBTAcmeLargeImageView *largeImageView = [[SBTAcmeLargeImageView alloc] init];
            largeImageView.urlStr = attachment.url;
            [self presentViewController:largeImageView animated:YES completion:^(void) {
                
            }];
        }
    }
}


#pragma mark - Helper methods


/**
 This method allows user to select if he wants to add a new update or a comment
 */
- (void) addNewLikePost {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                                             delegate: (id) self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Add a New Post", @"Add A Comment", nil];
    [actionSheet showInView:self.view];
}

/**
 User's action of adding update/comment is handled in here
 */
- (void) actionSheet:(UIActionSheet *) actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex {
    if (buttonIndex == 0) {
        // New entry
        ComposeUpdate *compose = [[ComposeUpdate alloc] init];
        compose.community = self.community;
        compose.delegateViewController = self;
        [self presentViewController:compose animated:YES completion:^(void) {
            
        }];
    } else if (buttonIndex == 1) {
        // New Comment
        ComposeUpdate *compose = [[ComposeUpdate alloc] init];
        compose.community = self.community;
        compose.entry = self.entry;
        compose.delegateViewController = self;
        [self presentViewController:compose animated:YES completion:^(void) {
            
        }];
    }
}

/**
 This method is called by ComposeUpdate when a status update is successful
 */
- (void) postStatus:(NSDictionary *) userDict {
    if (userDict == nil) {
        if (self.delegateViewController != nil && [self.delegateViewController respondsToSelector:@selector(popStatusUpdateView)]) {
            [self.delegateViewController performSelector:@selector(popStatusUpdateView)];
        }
    } else {
        NSError *error = [userDict objectForKey:@"error"];
        if (error == nil) {
            UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
            [self getEntryWithCompletionHandler:^(BOOL success) {
                if (success)
                    [self.tableView reloadData];
                [progressView dismissWithClickedButtonIndex:100 animated:YES];
                [self showAlertViewWithTitle:@"" message:@"Comment is posted successfully!"];
            }];
            if ([self.delegateViewController isKindOfClass:[SBTAcmeCommunityView class]]) {
                ((SBTAcmeCommunityView *)self.delegateViewController).isStatusChanged = [NSNumber numberWithBool:YES];
            }
        } else {
            [self showAlertViewWithTitle:@"" message:@"Oops there was a problem while uploading!"];
            if (IS_DEBUGGING)
                [FBLog log:[error description] from:self];
        }
    }
}

/**
 See who liked the entry
 */
- (void) whoLikeButtonIsTapped:(LikeButton *) button {
    IBMActivityStreamEntry *entry = button.entry;
    
    if ([entry.numLikes intValue] == 0) {
        return;
    }
    
    UIAlertView *progressView = [SBTAcmeUtils showProgressBar];
    
    NSString *eId = self.entry.eId;
    if ([self.entry.verb isEqualToString:@"like"]) {
        if ([self.entry.objectObjectType isEqualToString:@"comment"]) {
            eId = entry.targetId;
        } else {
            eId = entry.objectId;
        }
    } else {
        eId =  entry.objectId;
    }
    
    IBMConnectionsActivityStreamService *actStrService = [[IBMConnectionsActivityStreamService alloc] init];
    NSString *path = [NSString stringWithFormat:@"connections/opensocial/rest/ublog/@all/@all/%@/likes", eId];
    //path = [path stringByAppendingFormat:@"/%@", self.myProfile.userId];
    [[actStrService getClientService] initGetRequestWithPath:path parameters:nil format:RESPONSE_JSON success:^(id response, NSDictionary *resultDict) {
        
        NSMutableArray *peopleLiked = [[NSMutableArray alloc] init];
        NSMutableArray *list = [resultDict objectForKey:@"list"];
        for (NSDictionary *item in list) {
            NSDictionary *author = [item objectForKey:@"author"];
            IBMConnectionsProfile *profile = [[IBMConnectionsProfile alloc] init];
            NSString *actorIdPattern = @"urn:lsid:lconn.ibm.com:profiles.person:";
            if ([[author valueForKey:@"id"] hasPrefix:actorIdPattern]) {
                profile.userId = [[author valueForKey:@"id"] substringFromIndex:[actorIdPattern length]];
            } else {
                profile.userId = [author valueForKey:@"id"];
            }
            profile.displayName = [author valueForKey:@"displayName"];
            [peopleLiked addObject:profile];
        }
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
        SBTProfileListView *listView = [[SBTProfileListView alloc] init];
        listView.listOfProfiles = peopleLiked;
        listView.title = @"Likes";
        [self.navigationController pushViewController:listView animated:YES];
    } failure:^(id response, NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
        
        [progressView dismissWithClickedButtonIndex:100 animated:YES];
    }];
}

/**
 Like an entry
 */
- (void) likeButtonIsTapped:(LikeButton *) button {
    
    IBMActivityStreamEntry *entry = button.entry;
    IBMConnectionsActivityStreamService *actStrService = [[IBMConnectionsActivityStreamService alloc] init];
    NSString *eId = entry.eId;
    NSString *path;
    if ([entry.verb isEqualToString:@"like"]) {
        if ([entry.objectObjectType isEqualToString:@"comment"]) {
            eId = entry.targetId;
            path = [NSString stringWithFormat:@"connections/opensocial/rest/ublog/@all/@all/%@/likes", eId];
        } else {
            eId = entry.objectId;
            path = [NSString stringWithFormat:@"connections/opensocial/rest/ublog/@all/@all/%@/likes", eId];
        }
    } else {
        eId = entry.objectId;
        path = [NSString stringWithFormat:@"connections/opensocial/rest/ublog/@all/@all/%@/likes", eId];
    }
    
    if ([SBTAcmeUtils didILikeThisEntry:entry] == NO) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"application/json", @"Content-Type",
                                        nil];
        [[actStrService getClientService] initPostRequestWithPath:path headers:headers parameters:nil format:RESPONSE_JSON success:^(id response, id result) {
            if ([self.delegateViewController isKindOfClass:[SBTAcmeCommunityView class]]) {
                ((SBTAcmeCommunityView *)self.delegateViewController).isStatusChanged = [NSNumber numberWithBool:YES];
            }
            
            [self getEntryWithCompletionHandler:^(BOOL success) {
                if (success)
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:button.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        } failure:^(id response, NSError *error) {
            if (IS_DEBUGGING)
                [FBLog log:[error description] from:self];
        }];
    } else {
        [[actStrService getClientService] initDeleteRequestWithPath:path parameters:nil format:RESPONSE_JSON success:^(id response, id result) {
            if ([self.delegateViewController isKindOfClass:[SBTAcmeCommunityView class]]) {
                ((SBTAcmeCommunityView *)self.delegateViewController).isStatusChanged = [NSNumber numberWithBool:YES];
            }
            [self getEntryWithCompletionHandler:^(BOOL success) {
                if (success)
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:button.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        } failure:^(id response, NSError *error) {
            if (IS_DEBUGGING)
                [FBLog log:[error description] from:self];
        }];
    }
}

/**
 This method allows user to get status update before showing the view
 !!! We may need to shorten this, I've implement it this way, as I couldn't find any doc otherwise !!!
 */
- (void) getEntryWithCompletionHandler:(void (^)(BOOL)) completionHandler {
        
    NSString *eId = self.entry.eId;
    if ([self.entry.verb isEqualToString:@"like"]) {
        if ([self.entry.objectObjectType isEqualToString:@"comment"]) {
            eId = self.entry.targetId;
        } else {
            eId = self.entry.objectId;
        }
    } else {
        if ([self.entry.objectObjectType isEqualToString:@"comment"]) {
            eId = self.entry.targetId;
        } else {
            eId = self.entry.objectId;
        }
    }
    
    // First get the status update entry
    IBMConnectionsBasicEndPoint *endPoint = (IBMConnectionsBasicEndPoint *) [IBMEndPoint findEndPoint:@"connections"];
    NSString *path = [NSString stringWithFormat:@"connections/opensocial/basic/rest/ublog/@me/@all/%@", eId];
    [endPoint initGetRequestWithPath:path parameters:nil format:RESPONSE_JSON success:^(id response, NSDictionary *result) {
        NSDictionary *resultDict = [result objectForKey:@"entry"];
        IBMActivityStreamEntry *entry = [[IBMActivityStreamEntry alloc] init];
        entry.summary = [resultDict objectForKey:@"summary"];
        entry.numComments = [[resultDict objectForKey:@"replies"] objectForKey:@"totalItems"];
        entry.objectType = [resultDict objectForKey:@"objectType"];
        entry.objectObjectType = [resultDict objectForKey:@"objectType"];
        entry.eId = [resultDict objectForKey:@"id"];
        entry.objectId = [resultDict objectForKey:@"id"];
        entry.numLikes = [[resultDict objectForKey:@"likes"] objectForKey:@"totalItems"];
        entry.published = [resultDict objectForKey:@"published"];
        entry.updated = [resultDict objectForKey:@"published"];
        IBMActivityStreamActor *actor = [[IBMActivityStreamActor alloc] init];
        NSDictionary *authorD = [resultDict objectForKey:@"author"];
        NSString *actorIdPattern = @"urn:lsid:lconn.ibm.com:profiles.person:";
        if ([[authorD valueForKey:@"id"] hasPrefix:actorIdPattern]) {
            actor.aId = [[authorD valueForKey:@"id"] substringFromIndex:[actorIdPattern length]];
        } else {
            actor.aId = [authorD valueForKey:@"id"];
        }
        actor.name = [authorD valueForKey:@"displayName"];
        entry.plainTitle = actor.name;
        entry.actor = actor;
        entry.verb = @"note";
        entry.attachments = [self fetchAttachment:(NSMutableDictionary *) resultDict];
        self.entry = entry;
        
        // Now gets all the comments associated with this entry
        NSString *nPath = [NSString stringWithFormat:@"connections/opensocial/basic/rest/ublog/@me/@all/%@/comments", eId];
        [endPoint initGetRequestWithPath:nPath parameters:nil format:RESPONSE_JSON success:^(id response, NSDictionary *resultDict) {
            NSMutableArray *replies = [[NSMutableArray alloc] init];
            NSMutableArray *list = [resultDict objectForKey:@"list"];
            for (NSDictionary *item in list) {
                IBMActivityStreamEntry *comment = [[IBMActivityStreamEntry alloc] init];
                comment.objectType = @"comment";
                comment.objectObjectType = @"comment";
                comment.verb = @"comment";
                comment.objectId = [item objectForKey:@"id"];
                comment.eId = [item objectForKey:@"id"];
                comment.summary = [item objectForKey:@"summary"];
                comment.updated = [item objectForKey:@"published"];
                comment.published = [item objectForKey:@"published"];
                NSDictionary *authorDict = [item objectForKey:@"author"];
                IBMActivityStreamActor *actor = [[IBMActivityStreamActor alloc] init];
                NSString *actorIdPattern = @"urn:lsid:lconn.ibm.com:profiles.person:";
                if ([[authorDict valueForKey:@"id"] hasPrefix:actorIdPattern]) {
                    actor.aId = [[authorDict valueForKey:@"id"] substringFromIndex:[actorIdPattern length]];
                } else {
                    actor.aId = [authorDict valueForKey:@"id"];
                }
                
                actor.name = [authorDict objectForKey:@"displayName"];
                comment.actor = actor;
                NSDictionary *likesDict = [item objectForKey:@"likes"];
                comment.numLikes = [likesDict objectForKey:@"totalItems"];
                comment.targetLikes = [self fetchLikes:(NSMutableDictionary *) item];
                
                [replies addObject:comment];
            }
            
            self.entry.replies = replies;
            
            // Now lets get the likes for the entry
            NSString *path = [NSString stringWithFormat:@"connections/opensocial/rest/ublog/@all/@all/%@/likes", eId];
            [endPoint initGetRequestWithPath:path parameters:nil format:RESPONSE_JSON success:^(id response, NSDictionary *resultDict) {
                NSMutableArray *peopleLiked = [[NSMutableArray alloc] init];
                NSMutableArray *list = [resultDict objectForKey:@"list"];
                for (NSDictionary *item in list) {
                    NSDictionary *author = [item objectForKey:@"author"];
                    IBMActivityStreamActor *member = [[IBMActivityStreamActor alloc] init];
                    NSString *actorIdPattern = @"urn:lsid:lconn.ibm.com:profiles.person:";
                    if ([[author valueForKey:@"id"] hasPrefix:actorIdPattern]) {
                        member.aId = [[author valueForKey:@"id"] substringFromIndex:[actorIdPattern length]];
                    } else {
                        member.aId = [author valueForKey:@"id"];
                    }
                    member.name = [author valueForKey:@"displayName"];
                    [peopleLiked addObject:member];
                }
                
                self.entry.objectLikes = peopleLiked;
                
                completionHandler(YES);
            } failure:^(id response, NSError *error) {
                if (IS_DEBUGGING)
                    [FBLog log:[error description] from:self];
                
                completionHandler(NO);
            }];
        } failure:^(id response, NSError *error) {
            if (IS_DEBUGGING)
                [FBLog log:[error description] from:self];
            
            completionHandler(NO);
        }];
    } failure:^(id response, NSError *error) {
        if (IS_DEBUGGING)
            [FBLog log:[error description] from:self];
        
        completionHandler(NO);
    }];
}

- (NSMutableArray *) fetchLikes:(NSMutableDictionary *) dict {
    NSMutableArray *allLikes = [[NSMutableArray alloc] init];
    NSDictionary *likes = [dict objectForKey:@"likes"];
    if (likes != nil) {
        NSMutableArray *items = [likes objectForKey:@"items"];
        if (items != nil && [items count] > 0) {
            for (NSDictionary *item in items) {
                IBMActivityStreamActor *actor = [[IBMActivityStreamActor alloc] init];
                NSString *actorIdPattern = @"urn:lsid:lconn.ibm.com:profiles.person:";
                if ([[item valueForKey:@"id"] hasPrefix:actorIdPattern]) {
                    actor.aId = [[item valueForKey:@"id"] substringFromIndex:[actorIdPattern length]];
                } else {
                    actor.aId = [item valueForKey:@"id"];
                }
                actor.name = [item objectForKey:@"displayName"];
                [allLikes addObject:actor];
            }
        }
    }
    
    return allLikes;
}

- (NSMutableArray *) fetchAttachment:(NSMutableDictionary *) object {
    
    NSMutableArray *listOfAttachments = [[NSMutableArray alloc] init];
    NSMutableArray *attachments = [object objectForKey:@"attachments"];
    for (NSDictionary *attachmentDict in attachments) {
        IBMActivityStreamAttachment *attachment = [[IBMActivityStreamAttachment alloc] init];
        attachment.aId = [attachmentDict objectForKey:@"id"];
        attachment.displayName = [attachmentDict objectForKey:@"displayName"];
        attachment.summary = [attachmentDict objectForKey:@"summary"];
        NSDictionary *authorDict = [attachmentDict objectForKey:@"author"];
        
        IBMActivityStreamActor *author = [[IBMActivityStreamActor alloc] init];
        author.aId = [authorDict objectForKey:@"id"];
        author.name = [authorDict objectForKey:@"displayName"];
        author.type = [authorDict objectForKey:@"objectType"];
        
        attachment.author = author;
        attachment.published = [attachmentDict objectForKey:@"published"];
        attachment.url = [attachmentDict objectForKey:@"url"];
        if ([attachmentDict objectForKey:@"image"] != nil) {
            attachment.isImage = [NSNumber numberWithBool:YES];
            NSDictionary *imageDict = [attachmentDict objectForKey:@"image"];
            attachment.imageUrl = [imageDict objectForKey:@"url"];
        } else {
            attachment.isImage = [NSNumber numberWithBool:NO];
        }
        
        [listOfAttachments addObject:attachment];
    }
    
    return listOfAttachments;
}

- (void) showAlertViewWithTitle:(NSString *) title message:(NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

@end
