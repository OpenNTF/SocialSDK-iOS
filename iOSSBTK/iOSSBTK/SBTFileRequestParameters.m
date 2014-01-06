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

#import "SBTFileRequestParameters.h"

@implementation SBTFileRequestParameters

NSString *const	REMOVETAG					= @"removeTag";
NSString *const	ITEMID						= @"itemId";
NSString *const	VISIBILITY					= @"visibility";
NSString *const	IDENTIFIER					= @"identifier";
NSString *const	SHAREWITH					= @"shareWith";
NSString *const	SHARESUMMARY				= @"shareSummary";
NSString *const	CREATOR						= @"creator";
NSString *const	PAGE						= @"page";
NSString *const	PS							= @"ps";
NSString *const	SI							= @"sI";
NSString *const	INCLUDEEXTENDEDATTRIBUTES	= @"includeExtendedAttributes";
NSString *const	ACLS						= @"acls";
NSString *const	DIRECTION					= @"direction";
NSString *const	SC							= @"sC";
NSString *const	INCLUDEPATH					= @"includePath";
NSString *const	INCLUDETAGS					= @"includeTags";
NSString *const	SORTBY						= @"sortBy";
NSString *const	SORTORDER					= @"sortOrder";
NSString *const	TAG							= @"tag";
NSString *const	FILETYPE					= @"fileType";
NSString *const	FORMAT						= @"format";
NSString *const	INCLUDECOUNT				= @"includeCount";
NSString *const	ACCESS						= @"access";
NSString *const	SHARED						= @"shared";
NSString *const	SHAREDWITHME				= @"sharedWithMe";
NSString *const	ADDED						= @"added";
NSString *const	ADDEDBY						= @"addedBy";
NSString *const	INCLUDEQUOTA				= @"includeQuota";
NSString *const	SHAREPERMISSION				= @"sharePermission";
NSString *const	SHAREDBY					= @"sharedBy";
NSString *const	SHAREDWITH					= @"sharedWith";
NSString *const	SEARCH						= @"search";
NSString *const	CATEGORY					= @"category";
NSString *const	INLINE						= @"inline";
NSString *const	INCLUDELIBRARYINFO			= @"includeLibraryInfo";
NSString *const	INCLUDENOTIFICATION			= @"includeNotification";
NSString *const	RECOMMENDATION				= @"recommendation";
NSString *const	VERSIONUUID					= @"versionUuid";
NSString *const	RESTRICTEDVISIBILITY		= @"restrictedVisibility";
NSString *const	LOCK						= @"type";
NSString *const	LIBRARYTYPE					= @"libraryType";
NSString *const	EMAIL						= @"email";
NSString *const	USERSTATE					= @"userState";

@end
