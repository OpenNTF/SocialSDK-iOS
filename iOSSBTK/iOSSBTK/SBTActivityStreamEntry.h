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

#import <Foundation/Foundation.h>
#import "SBTActivityStreamCommunity.h"
#import "SBTActivityStreamAttachment.h"

@interface SBTActivityStreamEntry : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *verb;
@property (strong, nonatomic) NSString *shortTitle;
@property (strong, nonatomic) SBTActivityStreamActor *actor;
@property (strong, nonatomic) NSString *objectType;
@property (strong, nonatomic) NSString *published;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *updated;
@property (strong, nonatomic) NSString *eId;
@property (strong, nonatomic) SBTActivityStreamCommunity *community;
@property (strong, nonatomic) NSMutableArray *attachments;
@property (strong, nonatomic) NSNumber *containAttachment;

#pragma mark - object properties
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *objectDisplayName;
@property (strong, nonatomic) NSString *objectSummary;
@property (strong, nonatomic) NSString *objectObjectType;
@property (strong, nonatomic) NSString *objectUrl;
@property (strong, nonatomic) NSMutableArray *objectLikes;

#pragma mark - target properties
@property (strong, nonatomic) NSString *targetSummary;
@property (strong, nonatomic) NSString *targetObjectType;
@property (strong, nonatomic) NSString *targetId;
@property (strong, nonatomic) NSString *targetDisplayName;
@property (strong, nonatomic) NSString *targetUrl;
@property (strong, nonatomic) NSMutableArray *targetLikes;

#pragma mark - connections properties

@property (strong, nonatomic) NSNumber *actionable;
@property (strong, nonatomic) NSNumber *broadcast;
@property (strong, nonatomic) NSNumber *isPublic;
@property (strong, nonatomic) NSNumber *saved;
@property (strong, nonatomic) NSString *atomUrl;
@property (strong, nonatomic) NSString *containerId;
@property (strong, nonatomic) NSString *containerName;
@property (strong, nonatomic) NSString *plainTitle;
@property (strong, nonatomic) NSNumber *followedResource;
@property (strong, nonatomic) NSString *rollUpId;
@property (strong, nonatomic) NSString *rollUpUrl;

#pragma mark - open social/contex/embed

@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *connectionsContentUrl;
@property (strong, nonatomic) NSString *eventType;
@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) NSString *iconUrl;
@property (strong, nonatomic) NSNumber *numLikes;
@property (strong, nonatomic) NSNumber *numComments;
@property (strong, nonatomic) NSString *contextId;
@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) NSString *tags;
@property (strong, nonatomic) NSString *itemUrl;
@property (strong, nonatomic) NSString *gadget;
@property (strong, nonatomic) NSString *embedUrl;

#pragma mark - microblogs

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *repliesUrl;
@property (strong, nonatomic) NSMutableArray *replies;
@property (strong, nonatomic) NSString *likesUrl;

#pragma mark - public methods

+ (SBTActivityStreamEntry *) createActivityStreamEntryObjectFromDictionary:(NSDictionary *) dict;
- (NSString *) description;

@end
