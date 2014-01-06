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

//  This class provides all the service for accessing and updating the Connections' profile

#import "SBTConnectionsProfileService.h"
#import "SBTXMLDocument.h"
#import "FBLog.h"
#import "SBTConstants.h"

@implementation SBTConnectionsProfileService

const NSString *PROFILE_URL = @"/profiles";

#pragma mark - initialization methods here

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

#pragma mark - core methods here

- (void) getProfile:(NSString *) userId success:(void (^)(SBTConnectionsProfile *)) success failure:(void (^)(NSError *)) failure {
    
    if (userId == nil) {
        return;// Return error here
    }
    
    // Put parameters into a dictionary
    NSMutableDictionary *dict;
    if ([self isEmailWithString:userId])
        dict = [NSMutableDictionary dictionaryWithObject:userId forKey:@"email"];
    else
        dict = [NSMutableDictionary dictionaryWithObject:userId forKey:@"userid"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/atom%@/profile.do", PROFILE_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:dict
                                             format:RESPONSE_XML
                                            success:^(id response,id result) {
                                                SBTConnectionsProfile *connProfile = [[SBTConnectionsProfile alloc] initWithXMLDocument:result];
                                                success(connProfile);
                                            } failure:^(id response, NSError * error) {
                                                //NSLog(@"Error: %@", error);
                                                failure(error);
                                            }];
}

- (void) updateProfile:(SBTConnectionsProfile *) profile success:(void (^)(BOOL)) success failure:(void (^)(NSError *)) failure {
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"application/atom+xml", @"Content-Type",
                             nil];
    NSString *body = [profile constructUpdateRequestBody];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"vcard", @"output",
                                   @"full", @"format",
                                   profile.userId, @"userid",
                                   nil];
    
    [params setObject:body forKey:@"body"];
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/atom%@/profileEntry.do", PROFILE_URL, auth];
    [[self getClientService] initPutRequestWithPath:urlStr
                                            headers:headers
                                         parameters:params
                                             format:RESPONSE_NONE
                                            success:^(id response, id result) {
                                                
                                                [profile.fieldsDict removeAllObjects];
                                                success(YES);
                                            } failure:^(id response, NSError * error) {
                                                
                                                failure(error);
                                            }];
}

- (void) searchProfilesWithParameters:(NSMutableDictionary *) parameters success:(void (^)(NSMutableArray *listOfProfiles)) success failure:(void (^)(NSError *)) failure {
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/atom%@/search.do", PROFILE_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                // Parse the xml file and return the list of profiles
                                                NSMutableArray *list = [self convertToProfileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getReportToChainWithUserId:(NSString *) userId parameters:(NSMutableDictionary *) parameters success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure {
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    if ([SBTUtils isEmail:userId])
        [parameters setValue:userId forKey:@"email"];
    else
        [parameters setValue:userId forKey:@"userid"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/atom%@/reportingChain.do", PROFILE_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                // Parse the xml file and return the list of profiles
                                                NSMutableArray *list = [self convertToProfileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getDirectReportsWithUserId:(NSString *) userId parameters:(NSMutableDictionary *) parameters success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure {
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    if ([SBTUtils isEmail:userId])
        [parameters setValue:userId forKey:@"email"];
    else
        [parameters setValue:userId forKey:@"userid"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/atom%@/peopleManaged.do", PROFILE_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                // Parse the xml file and return the list of profiles
                                                NSMutableArray *list = [self convertToProfileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getColleaguesWithProfile:(SBTConnectionsProfile *) profile success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                @"colleague",@"connectionType",
                                @"profile", @"outputType",
                                profile.userId, @"userid",
                                nil];
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/atom%@/connections.do", PROFILE_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                //NSLog(@"Success: %@", [((IBMXMLDocument *) result).rootElement description]);
                                                // Parse the xml file and return the list of profiles
                                                NSMutableArray *list = [self convertToProfileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) getColleaguesWithProfile:(SBTConnectionsProfile *) profile parameters:(NSMutableDictionary *) parameters success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure {
    
    if (parameters == nil)
        parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setValue:@"colleague" forKey:@"connectionType"];
    [parameters setValue:profile.userId forKey:@"userid"];
    
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *path = [NSString stringWithFormat:@"%@/atom%@/connections.do", PROFILE_URL, auth];
    [[self getClientService] initGetRequestWithPath:path
                                         parameters:parameters
                                             format:RESPONSE_XML
                                            success:^(id response, id result) {
                                                // Parse the xml file and return the list of profiles
                                                NSMutableArray *list = [self convertToProfileListWithXML:result];
                                                success(list);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];
}

- (void) uploadProfilePhotoForUserId:(NSString *) userId data:(NSData *) data contentType:(NSString *) type success:(void (^)(BOOL))success failure:(void (^)(NSError *))failure {
    
    if (data == nil) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:@"Data is nil for profile photo upload" from:self];
        
        failure([NSError errorWithDomain:@"com.ibm.ProfileService" code:100 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Data cannot be nil", @"description", nil]]);
        return;
    }
    
    if (type == nil && !([type isEqualToString:@"image/png"] && [type isEqualToString:@"image/jpg"])) {
        if (IS_DEBUGGING_SBTK)
            [FBLog log:@"ContentType cannot be nil. It should be either image/png or image/jpg" from:self];
        
        failure([NSError errorWithDomain:@"com.ibm.ProfileService" code:100 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"ContentType cannot be nil. It should be either image/png or image/jpg", @"description", nil]]);
        return;
    }
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    type, @"Content-Type",
                                    nil];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:data forKey:@"body"];
    [params setValue:userId forKey:@"userid"];
    NSString *auth = @"";
    if ([[self.endPoint getAuthType] isEqualToString:OAUTH2]) {
        auth = [NSString stringWithFormat:@"/%@", [self.endPoint getAuthType]];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/photo.do", PROFILE_URL,auth];
    [[self getClientService] initPutRequestWithPath:urlStr
                                            headers:headers
                                         parameters:params
                                             format:RESPONSE_NONE
                                            success:^(id response, id result) {
                                                success(YES);
                                            } failure:^(id response, NSError * error) {
                                                failure(error);
                                            }];

}

#pragma mark - auxilary methods here

- (NSString *) getAuthType {
    return [self.endPoint getAuthType];
}

- (BOOL) isEmailWithString:(NSString *) str {
    if ([str rangeOfString:@"@"].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (NSMutableArray *) convertToProfileListWithXML:(SBTXMLDocument *) document {
    
    NSMutableArray *listOfProfiles = nil;
    if (document != nil) {
        
        NSError *error;
        NSDictionary *dict = [SBTConnectionsProfile namespacesForProfile];
        NSArray *entryList = [document nodesForXPath:@"/a:feed/a:entry" namespaces:dict error:&error];
        if (entryList != nil && [entryList count] > 0) {
            listOfProfiles = [[NSMutableArray alloc] init];
            for (GDataXMLElement *element in entryList) {
                // Create a new feed element and child
                GDataXMLElement *rootElement = [GDataXMLElement elementWithName:@"feed"];
                rootElement.namespaces = document.rootElement.namespaces;
                [rootElement addChild:element];
                
                // Make it a xml document
                SBTXMLDocument *doc = [[SBTXMLDocument alloc] initWithRootElement:rootElement];
                // Create a profile object and add it to the array
                SBTConnectionsProfile *profile = [[SBTConnectionsProfile alloc] initWithXMLDocument:doc];
                [listOfProfiles addObject:profile];
            }
        }
    }
    
    return listOfProfiles;
}

@end
