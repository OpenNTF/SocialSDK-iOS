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

#import "SBTActivityStreamEntry.h"

@implementation SBTActivityStreamEntry

+ (SBTActivityStreamEntry *) createActivityStreamEntryObjectFromDictionary:(NSDictionary *) dict {
    
    SBTActivityStreamEntry *entry = [[SBTActivityStreamEntry alloc] init];
    
    NSMutableDictionary *actorDict = [dict objectForKey:@"actor"];
    NSMutableDictionary *connectionsDict = [dict objectForKey:@"connections"];
    NSMutableDictionary *openSocialDict = [dict objectForKey:@"openSocial"];
    NSMutableDictionary *embedDict = [openSocialDict objectForKey:@"embed"];
    NSMutableDictionary *contextDict = [embedDict objectForKey:@"context"];
    NSMutableDictionary *objectDict = [dict objectForKey:@"object"];
    NSMutableDictionary *targetDict = [dict objectForKey:@"target"];
    
    entry.published = [dict valueForKey:@"published"];
    entry.url = [dict valueForKey:@"url"];
    entry.title = [dict valueForKey:@"title"];
    entry.verb = [dict valueForKey:@"verb"];
    entry.updated = [dict valueForKey:@"updated"];
    entry.eId = [dict valueForKey:@"id"];
    entry.content = [dict valueForKey:@"content"];
    
    if (targetDict != nil) {
        NSString *objectType = [targetDict objectForKey:@"objectType"];
        entry.objectType = objectType;
        if (objectType != nil && [objectType isEqualToString:@"community"]) {
            // Create community and set it below
            entry.community = [self fetchCommunity:targetDict];
        }
    }
    
    SBTActivityStreamActor *actor = [[SBTActivityStreamActor alloc] init];
    actor.name = [actorDict valueForKey:@"displayName"];
    NSString *actorIdPattern = @"urn:lsid:lconn.ibm.com:profiles.person:";
    if ([[actorDict valueForKey:@"id"] hasPrefix:actorIdPattern]) {
        actor.aId = [[actorDict valueForKey:@"id"] substringFromIndex:[actorIdPattern length]];
    } else {
        actor.aId = [actorDict valueForKey:@"id"];
    }
    actor.type = [actorDict valueForKey:@"objectType"];
    entry.actor = actor;
    
    // Object
    entry.objectId = [objectDict valueForKey:@"id"];
    entry.objectDisplayName = [objectDict valueForKey:@"displayName"];;
    entry.objectSummary = [objectDict valueForKey:@"summary"];;
    entry.objectObjectType = [objectDict valueForKey:@"objectType"];;
    entry.objectUrl = [objectDict valueForKey:@"url"];;
    entry.objectLikes = [self fetchLikes:objectDict];
    
    // Target
    entry.targetSummary = [targetDict valueForKey:@"summary"];
    entry.targetObjectType = [targetDict valueForKey:@"objectType"];
    entry.targetId = [targetDict valueForKey:@"id"];
    entry.targetDisplayName = [targetDict valueForKey:@"displayName"];
    entry.targetUrl = [targetDict valueForKey:@"url"];
    entry.targetLikes = [self fetchLikes:targetDict];
    
    // Connections
    entry.actionable = [connectionsDict valueForKey:@"actionable"];
    entry.broadcast = [connectionsDict valueForKey:@"broadcast"];
    entry.rollUpId = [connectionsDict valueForKey:@"rollupid"];
    entry.isPublic = [connectionsDict valueForKey:@"isPublic"];
    entry.saved = [connectionsDict valueForKey:@"saved"];
    entry.rollUpUrl = [connectionsDict valueForKey:@"rollupUrl"];
    entry.shortTitle = [connectionsDict valueForKey:@"shortTitle"];
    entry.containerId = [connectionsDict valueForKey:@"containerId"];
    entry.containerName = [connectionsDict valueForKey:@"containerName"];
    entry.plainTitle = [connectionsDict valueForKey:@"plainTitle"];
    entry.atomUrl = [connectionsDict valueForKey:@"atomUrl"];
    entry.followedResource = [connectionsDict valueForKey:@"followedResource"];
    entry.likesUrl = [connectionsDict valueForKey:@"likeService"];
    
    
    entry.summary = [contextDict valueForKey:@"summary"];
    entry.connectionsContentUrl = [contextDict valueForKey:@"connectionsContentUrl"];
    entry.eventType = [contextDict valueForKey:@"eventType"];
    entry.eventId = [contextDict valueForKey:@"eventId"];
    entry.iconUrl = [contextDict valueForKey:@"iconUrl"];
    if ([contextDict objectForKey:@"numLikes"] != nil) {
        entry.numLikes = [contextDict objectForKey:@"numLikes"];
    } else {
        entry.numLikes = [NSNumber numberWithInt:0];
    }
    
    if ([contextDict objectForKey:@"numComments"] != nil) {
        entry.numComments = [contextDict objectForKey:@"numComments"];
    } else {
        entry.numComments = [NSNumber numberWithInt:0];
    }
    entry.contextId = [contextDict valueForKey:@"id"];
    entry.eventTitle = [contextDict valueForKey:@"eventTitle"];
    entry.tags = [contextDict valueForKey:@"tags"];
    entry.itemUrl = [contextDict valueForKey:@"itemUrl"];
    entry.embedUrl = [embedDict valueForKey:@"url"];
    entry.gadget = [embedDict valueForKey:@"gadget"];
    
    if (objectDict != nil) {
        // Get attachment info and set here
#warning Verify if this checking always holds while getting attachments
        
        NSMutableArray *temp = [self fetchAttachment:objectDict];
        if (temp != nil && [temp count] > 0)
            entry.attachments = temp;
        else
            entry.attachments = [self fetchAttachment:targetDict];
    }
    
    if (entry.numComments > 0) {
        // Get comments and set here
        entry.replies = [self fetchComments:targetDict];
    }
    
    return entry;
}

+ (NSMutableArray *) fetchLikes:(NSMutableDictionary *) objectDict {
    NSMutableArray *allLikes = [[NSMutableArray alloc] init];
    NSDictionary *likes = [objectDict objectForKey:@"likes"];
    if (likes != nil) {
        NSMutableArray *items = [likes objectForKey:@"items"];
        if (items != nil && [items count] > 0) {
            for (NSDictionary *item in items) {
                SBTActivityStreamActor *actor = [[SBTActivityStreamActor alloc] init];
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

+ (NSMutableArray *) fetchComments:(NSMutableDictionary *) targetDict {
    NSMutableArray *listToReturn = [[NSMutableArray alloc] init];
    NSMutableArray *list = [[targetDict objectForKey:@"replies"] objectForKey:@"items"];
    for (NSMutableDictionary *entry in list) {
        SBTActivityStreamEntry *newEntry = [[SBTActivityStreamEntry alloc] init];
        SBTActivityStreamActor *newActor = [[SBTActivityStreamActor alloc] init];
        if ([entry objectForKey:@"id"] == nil || [[entry objectForKey:@"id"] isEqualToString:@""]) {
            break;
        }
        
        newEntry.summary = [entry valueForKey:@"content"];
        newEntry.updated = [entry valueForKey:@"updated"];
        newEntry.eId = [entry valueForKey:@"id"];
        newEntry.objectType = [entry valueForKey:@"objectType"];
        
        NSDictionary *author = [entry objectForKey:@"author"];
        newActor.name = [author valueForKey:@"displayName"];
        NSString *actorIdPattern = @"urn:lsid:lconn.ibm.com:profiles.person:";
        if ([[author valueForKey:@"id"] hasPrefix:actorIdPattern]) {
            newActor.aId = [[author valueForKey:@"id"] substringFromIndex:[actorIdPattern length]];
        } else {
            newActor.aId = [author valueForKey:@"id"];
        }
        newActor.type = [author valueForKey:@"objectType"];
        
        newEntry.actor = newActor;
        
        [listToReturn addObject:newEntry];
    }
    
    return listToReturn;
}

+ (SBTActivityStreamCommunity *) fetchCommunity:(NSMutableDictionary *) targetDict {
    NSString *communityPattern = @"urn:lsid:lconn.ibm.com:communities.community:";
    SBTActivityStreamCommunity *community = [[SBTActivityStreamCommunity alloc] init];
    NSString *commId = [targetDict objectForKey:@"id"];
    if ([commId hasPrefix:communityPattern]) {
        commId = [commId substringFromIndex:[communityPattern length]];
    }
    community.communityId = commId;
    community.communityName = [targetDict valueForKey:@"displayName"];
    
    return community;
}

+ (NSMutableArray *) fetchAttachment:(NSMutableDictionary *) object {
    
    NSMutableArray *listOfAttachments = [[NSMutableArray alloc] init];
    NSMutableArray *attachments = [object objectForKey:@"attachments"];
    for (NSDictionary *attachmentDict in attachments) {
        SBTActivityStreamAttachment *attachment = [[SBTActivityStreamAttachment alloc] init];
        attachment.aId = [attachmentDict objectForKey:@"id"];
        attachment.displayName = [attachmentDict objectForKey:@"displayName"];
        attachment.summary = [attachmentDict objectForKey:@"summary"];
        NSDictionary *authorDict = [attachmentDict objectForKey:@"author"];
        
        SBTActivityStreamActor *author = [[SBTActivityStreamActor alloc] init];
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

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"Title: %@\n", self.title];
    description = [description stringByAppendingFormat:@"Verb: %@\n", self.verb];
    description = [description stringByAppendingFormat:@"Short title: %@\n", self.shortTitle];
    description = [description stringByAppendingFormat:@"Actor: %@\n", [self.actor description]];
    description = [description stringByAppendingFormat:@"Object type: %@\n", self.objectType];
    description = [description stringByAppendingFormat:@"Published: %@\n", self.published];
    description = [description stringByAppendingFormat:@"Url: %@\n", self.url];
    description = [description stringByAppendingFormat:@"Updated: %@\n", self.updated];
    description = [description stringByAppendingFormat:@"Entry id: %@\n", self.eId];
    description = [description stringByAppendingFormat:@"Community: %@\n", [self.community description]];
    description = [description stringByAppendingFormat:@"Attachment: %@\n", [self.attachments description]];
    description = [description stringByAppendingFormat:@"Contain attachment: %@\n", [self.containAttachment description]];
    description = [description stringByAppendingFormat:@"actionable: %@\n", [self.actionable description]];
    description = [description stringByAppendingFormat:@"Broadcast: %@\n", [self.broadcast description]];
    description = [description stringByAppendingFormat:@"isPublic: %@\n", [self.isPublic description]];
    description = [description stringByAppendingFormat:@"Saved: %@\n", [self.saved description]];
    description = [description stringByAppendingFormat:@"Atom url: %@\n", self.atomUrl];
    description = [description stringByAppendingFormat:@"Container id: %@\n", self.containerId];
    description = [description stringByAppendingFormat:@"Container name: %@\n", self.containerName];
    description = [description stringByAppendingFormat:@"Plain title: %@\n", self.plainTitle];
    description = [description stringByAppendingFormat:@"Folllowed resource: %@\n", [self.followedResource description]];
    description = [description stringByAppendingFormat:@"Roll up id: %@\n", self.rollUpId];
    description = [description stringByAppendingFormat:@"Roll up url: %@\n", self.rollUpUrl];
    description = [description stringByAppendingFormat:@"Summary: %@\n", self.summary];
    description = [description stringByAppendingFormat:@"connectionsContentUrl: %@\n", self.connectionsContentUrl];
    description = [description stringByAppendingFormat:@"Event type: %@\n", self.eventType];
    description = [description stringByAppendingFormat:@"Event id: %@\n", self.eventId];
    description = [description stringByAppendingFormat:@"Icon url: %@\n", self.iconUrl];
    description = [description stringByAppendingFormat:@"Num of likes: %@\n", [self.numLikes description]];
    description = [description stringByAppendingFormat:@"Num of comments: %@\n", [self.numComments description]];
    description = [description stringByAppendingFormat:@"Context id: %@\n", self.contextId];
    description = [description stringByAppendingFormat:@"Event title: %@\n", self.eventTitle];
    description = [description stringByAppendingFormat:@"Tags: %@\n", self.tags];
    description = [description stringByAppendingFormat:@"Item url: %@\n", self.itemUrl];
    description = [description stringByAppendingFormat:@"Embed url: %@\n", self.embedUrl];
    description = [description stringByAppendingFormat:@"Gadget: %@\n", self.gadget];
    
    description = [description stringByAppendingFormat:@"Content: %@\n", self.content];
    description = [description stringByAppendingFormat:@"Replies url: %@\n", self.repliesUrl];
    description = [description stringByAppendingFormat:@"Replies: %@\n", [self.replies description]];
    description = [description stringByAppendingFormat:@"Likes url: %@\n", self.likesUrl];
    
    return description;
}

@end
