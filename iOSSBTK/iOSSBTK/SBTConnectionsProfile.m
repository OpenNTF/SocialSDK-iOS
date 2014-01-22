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

#import "SBTConnectionsProfile.h"
#import "SBTUtils.h"
#import "SBTConstants.h"
#import "FBLog.h"

@interface SBTConnectionsProfile ()

@property (strong, nonatomic) NSMutableDictionary *xpathMap;
@property (strong, nonatomic) NSDictionary *vcardMap;

@end

@implementation SBTConnectionsProfile

@synthesize userId = _userId, displayName = _displayName, email = _email, title = _title, phoneNumber = _phoneNumber, department = _department, thumbnailURL = _thumbnailURL, profileURL = _profileURL, pronunciationURL = _pronunciationURL, about = _about, address = _address, uniqueId = _uniqueId;

ResponseType type;

- (id) init {
    if (self = [super init]) {
        [self initEnv];
        
        type = RESPONSE_XML;//Default format type
    }
    
    return self;
}

- (id) initWithXMLDocument:(SBTXMLDocument *) document {
    
    if (self = [super init]) {
        [self initEnv];
        
        type = RESPONSE_XML;
        self.xmlDocument = document;
    }
    
    return self;
}

/**
 Private method to initiliaze static variables
 */
- (void) initEnv {
    
    self.fieldsDict = [[NSMutableDictionary alloc] init];
    self.xpathMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     @"/a:feed/a:entry/a:contributor/snx:userid", @"uid",
     @"/a:feed/a:entry/a:contributor/a:name", @"name",
     @"/a:feed/a:entry/a:contributor/a:email", @"email",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:img[@class='photo' or @a:class='photo']/@*[contains(name(), 'src')]", @"photo",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div[@a:class='title'or @class='title']", @"title",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div[@class='org' or @a:class='org']/b:span[@class='organization-unit' or @a:class='organization-unit']", @"organizationUnit",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:a[@class='fn url' or @a:class='fn url']/@*[contains(name(), 'href')]", @"fnUrl",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div[@class='tel' or @a:class='tel']/b:span[@class='value' or @a:class='value']", @"telephoneNumber",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:span[@class='x-building' or @a:class='x-building']", @"bldgId",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:span[@class='x-floor' or @a:class='x-floor']", @"floor",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:div[@class='street-address' or @a:class='street-address']", @"streetAddress",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:div[@class='extended-address x-streetAddress2' or @a:class='extended-address x-streetAddress2']", @"extendedAddress",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:span[@class='locality' or @a:class='locality']", @"locality",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:span[@class='postal-code' or @a:class='postal-code']", @"postalCode",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:span[@class='region' or @a:class='region']", @"region",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:div[@class='country-name' or @a:class='country-name']", @"countryName",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div/b:a[@class='sound url' or @a:class='sound url']/@*[contains(name(), 'href')]", @"soundUrl",
     @"/a:feed/a:entry/a:summary", @"summary",
     @"/a:feed/a:entry/a:content/b:div/b:span/b:div[@class='uid' or @a:class='uid']", @"uniqueId",
     nil];
    self.vcardMap = [[NSDictionary alloc] initWithObjectsAndKeys:
                     @"X_ALTERNATE_LAST_NAME", @"alternateLastname",
                     @"X_BUILDING", @"bldgId",
                     @"X_BLOG_URL;VALUE", @"blogUrl",
                     @"X_COUNTRY_CODE", @"countryCode",
                     @"HONORIFIC_PREFIX", @"courtesyTitle",
                     @"X_DEPARTMENT_NUMBER", @"deptNumber",
                     @"X_DESCRIPTION", @"description",
                     @"FN", @"displayName",
                     @"EMAIL;INTERNET", @"email",
                     @"X_EMPLOYEE_NUMBER", @"employeeNumber",
                     @"X_EMPTYPE", @"employeeTypeCode",
                     @"ROLE", @"employeeTypeDesc",
                     @"X_EXPERIENCE", @"experience",
                     @"TEL;FAX", @"faxNumber",
                     @"X_FLOOR", @"floor",
                     @"EMAIL;X_GROUPWARE_MAIL", @"groupwareEmail",
                     @"UID", @"guid",
                     @"TEL;X_IP and TEL;PAGER*", @"ipTelephoneNumber",
                     @"X_IS_MANAGER", @"isManager",
                     @"TITLE", @"jobResp",
                     @"REV", @"lastUpdate",
                     @"X_MANAGER_UID", @"managerUid",
                     @"TEL;CELL", @"mobileNumber",
                     @"X_NATIVE_FIRST_NAME", @"nativeFirstName",
                     @"X_NATIVE_:LAST_NAME", @"nativeLastName",
                     @"X_OFFICE_NUMBER", @"officeName",
                     @"ORG", @"organizationTitle",
                     @"X_ORGANIZATION_CODE", @"orgId",
                     @"X_PAGER_ID", @"pagerId",
                     @"X_PAGER_PROVIDER", @"pagerServiceProvider",
                     @"X_PAGER_TYPE", @"pagerType",
                     @"NICKNAME", @"preferredFirstName",
                     @"X_PREFERRED_LANGUAGE", @"preferredLanguage",
                     @"X_PREFERRED_LAST_NAME", @"preferredLastName",
                     @"TEL;WORK", @"telephoneNumber",
                     @"TZ", @"timezone",
                     @"X_PROFILE_UID", @"uid",
                     @"X_BLOG_URL;VALUE", @"URL*",
                     @"ADR;WORK", @"workLocation",
                     @"X_WORKLOCATION_CODE", @"workLocationCode",
                     nil];
}

- (NSString *) userId {
    if (_userId == nil) {
        _userId = [self getFieldWithXPath:@"uid"];
    }
    
    return _userId;
}

- (NSString *) displayName {
    if (_displayName == nil) {
        _displayName = [self getFieldWithXPath:@"name"];
    }
    
    return _displayName;
}

- (NSString *) email {
    if (_email == nil) {
        _email = [self getFieldWithXPath:@"email"];
    }
    
    return _email;
}

- (NSString *) title {
    if (_title == nil) {
        _title = [self getFieldWithXPath:@"title"];
    }
    
    return _title;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    [self.fieldsDict setObject:title forKey:[self.vcardMap objectForKey:@"jobResp"]];
}

- (NSString *) phoneNumber {
    if (_phoneNumber == nil) {
        _phoneNumber = [self getFieldWithXPath:@"telephoneNumber"];
    }
    
    return _phoneNumber;
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = phoneNumber;
    
    [self.fieldsDict setObject:phoneNumber forKey:[self.vcardMap objectForKey:@"telephoneNumber"]];
}

- (NSString *) department {
    if (_department == nil) {
        _department = [self getFieldWithXPath:@"organizationUnit"];
    }
    
    return _department;
}

- (NSString *) thumbnailURL {
    if (_thumbnailURL == nil) {
        _thumbnailURL = [self getFieldWithXPath:@"photo"];
    }
    
    return _thumbnailURL;
}

- (NSString *) profileURL {
    if (_profileURL == nil) {
        _profileURL = [self getFieldWithXPath:@"fnUrl"];
    }
    
    return _profileURL;
}

- (NSString *) pronunciationURL {
    if (_pronunciationURL == nil) {
        _pronunciationURL = [self getFieldWithXPath:@"soundUrl"];
    }
    
    return _pronunciationURL;
}

- (NSString *) about {
    if (_about == nil) {
        _about = [self getFieldWithXPath:@"summary"];
    }
    
    return _about;
}

- (NSDictionary *) address {
    if (_address == nil) {
        NSString *bldgId = [self getFieldWithXPath:@"bldgId"];
        NSString *floor =  [self getFieldWithXPath:@"floor"];
        NSString *streetAddress =  [self getFieldWithXPath:@"streetAddress"];
        NSString *extStreetAddress =  [self getFieldWithXPath:@"extendedAddress"];
        NSString *localilty =  [self getFieldWithXPath:@"locality"];
        NSString *postalCode =  [self getFieldWithXPath:@"postalCode"];
        NSString *region =  [self getFieldWithXPath:@"region"];
        NSString *countryName =  [self getFieldWithXPath:@"countryName"];
        
        _address = [NSDictionary dictionaryWithObjectsAndKeys:
                    bldgId, @"bldgId",
                    floor, @"floor",
                    streetAddress, @"streetAddress",
                    extStreetAddress, @"extendedAddress",
                    localilty, @"locality",
                    postalCode, @"postalCode",
                    region, @"region",
                    countryName, @"countryName",
                    nil];
    }
    
    return _address;
}

- (void)setAddress:(NSDictionary *)address {
    _address = address;
    
    if (address != nil) {
        
        if ([address objectForKey:@"bldgId"] != nil)
            [self.fieldsDict setValue:[address objectForKey:@"bldgId"] forKey:[self.vcardMap objectForKey:@"bldgId"]];
        if ([address objectForKey:@"floor"] != nil)
            [self.fieldsDict setValue:[address objectForKey:@"floor"] forKey:[self.vcardMap objectForKey:@"floor"]];
        
        // Non editable
        /*
        if ([address objectForKey:@"streetAddress"] != nil)
            [self.fieldsDict setValue:[address objectForKey:@"streetAddress"] forKey:@"streetAddress"];
        if ([address objectForKey:@"extendedAddress"] != nil)
            [self.fieldsDict setValue:[address objectForKey:@"extendedAddress"] forKey:@"extendedAddress"];
        if ([address objectForKey:@"locality"] != nil)
            [self.fieldsDict setValue:[address objectForKey:@"locality"] forKey:@"locality"];
        if ([address objectForKey:@"postalCode"] != nil)
            [self.fieldsDict setValue:[address objectForKey:@"postalCode"] forKey:@"postalCode"];
        if ([address objectForKey:@"region"] != nil)
            [self.fieldsDict setValue:[address objectForKey:@"region"] forKey:@"region"];
        if ([address objectForKey:@"countryName"] != nil)
            [self.fieldsDict setValue:[address objectForKey:@"countryName"] forKey:@"countryName"];
         */
    }
}

- (NSString *) uniqueId {
    if (_uniqueId == nil) {
        _uniqueId = [self getFieldWithXPath:@"uniqueId"];
    }
    
    return _uniqueId;
}


/**
 Private method to query xml document with a xpath query
 @param fieldName: Name of the field to be returned
 @return text of the field
 */
- (NSString *) getFieldWithXPath:(NSString *) fieldName {
    
    NSError *error;
    NSDictionary *dict = [SBTConnectionsProfile namespacesForProfile];
    NSArray *list = [self.xmlDocument nodesForXPath:[self.xpathMap objectForKey:fieldName]
                                         namespaces:dict
                                              error:&error];
    // Check for an error
    if (error != nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
        
        return nil;
    }
    
    // Check if there is a result
    if (list == nil || [list count] == 0)
        return nil;
        
    return ((GDataXMLNode *)[list objectAtIndex:0]).stringValue;
}

- (NSString *) constructUpdateRequestBody {
    NSString *requestBody = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><entry xmlns:app=\"http://www.w3.org/2007/app\" xmlns:thr=\"http://purl.org/syndication/thread/1.0\" xmlns:fh=\"http://purl.org/syndication/history/1.0\" xmlns:snx=\"http://www.ibm.com/xmlns/prod/sn\" xmlns:opensearch=\"http://a9.com/-/spec/opensearch/1.1/\" xmlns=\"http://www.w3.org/2005/Atom\"><category term=\"profile\" scheme=\"http://www.ibm.com/xmlns/prod/sn/type\"></category><content type=\"text\">\nBEGIN:VCARD\nVERSION:2.1\n";
    for (NSString *key in self.fieldsDict) {
        requestBody = [requestBody stringByAppendingFormat:@"%@:%@\n", key, [self.fieldsDict objectForKey:key]];
    }
    requestBody = [requestBody stringByAppendingString:@"END:VCARD\n</content></entry>"];
    
    return requestBody;
}

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"User Id: %@\n", self.userId];
    description = [description stringByAppendingFormat:@"Name: %@\n", self.displayName];
    description = [description stringByAppendingFormat:@"Email: %@\n", self.email];
    description = [description stringByAppendingFormat:@"Title: %@\n", self.title];
    description = [description stringByAppendingFormat:@"Phone number: %@\n", self.phoneNumber];
    description = [description stringByAppendingFormat:@"Department: %@\n", self.department];
    description = [description stringByAppendingFormat:@"Thumbnail url: %@\n", self.thumbnailURL];
    description = [description stringByAppendingFormat:@"Profile url: %@\n", self.profileURL];
    description = [description stringByAppendingFormat:@"Pronounciation url: %@\n", self.pronunciationURL];
    description = [description stringByAppendingFormat:@"About: %@\n", self.about];
    description = [description stringByAppendingFormat:@"Address: %@\n", [self.address description]];
    description = [description stringByAppendingFormat:@"Unique Id: %@\n", self.uniqueId];
    
    return description;
}

+ (NSDictionary *) namespacesForProfile {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"http://www.ibm.com/xmlns/prod/sn" forKey:@"snx"];
    [dict setValue:@"http://www.w3.org/2005/Atom" forKey:@"a"];
    [dict setValue:@"http://www.w3.org/1999/xhtml" forKey:@"b"];
    
    return dict;
}


@end


