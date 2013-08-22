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

//  This class represent the Profile object for the Connections

#import <Foundation/Foundation.h>
#import "IBMXMLDocument.h"

@interface IBMConnectionsProfile : NSObject

#pragma mark - public properties

/* XML document that contains the Profile information */
@property (strong, nonatomic) IBMXMLDocument *xmlDocument;
/* User id of the person */
@property (strong, nonatomic) NSString *userId;
/* Name of the person */
@property (strong, nonatomic) NSString *displayName;
/* Email of the person */
@property (strong, nonatomic) NSString *email;
/* Title of the person */
@property (strong, nonatomic) NSString *title;
/* Phone number of the person */
@property (strong, nonatomic) NSString *phoneNumber;
/* Department of the person */
@property (strong, nonatomic) NSString *department;
/* Thumbnail url of the person */
@property (strong, nonatomic) NSString *thumbnailURL;
/* Profile url of the person */
@property (strong, nonatomic) NSString *profileURL;
/* Pronunciation url of the person */
@property (strong, nonatomic) NSString *pronunciationURL;
/* About of the person */
@property (strong, nonatomic) NSString *about;
/* Address of the person */
@property (strong, nonatomic) NSDictionary *address;
/* Unique id of the person */
@property (strong, nonatomic) NSString *uniqueId;

/* Fields dictionary for holding changed or created fields */
@property (strong, nonatomic) NSMutableDictionary *fieldsDict;

#pragma mark - methods

/**
 Default initiliazation method
 */
- (id) init;

/**
 Initiliazation with the xml document
 */
- (id) initWithXMLDocument:(IBMXMLDocument *) document;

/**
 This methods generates the body of the profile update by iterating "fieldsDict" object
 @return NSString: body of the request
 */
- (NSString *) constructUpdateRequestBody;

- (NSString *)description;

+ (NSDictionary *) namespacesForProfile;

@end
