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

#import "SBTCommunityMember.h"
#import "SBTConstants.h"
#import "SBTUtils.h"
#import "FBLog.h"

@interface SBTCommunityMember ()

@property (strong, nonatomic) NSMutableDictionary *xpathMap;

@end

@implementation SBTCommunityMember

@synthesize userId = _userId, name = _name, email = _email, role = _role;

- (id) init {
    if (self = [super init]) {
        [self initEnv];
    }
    
    return self;
}

- (id) initWithXMLDocument:(SBTXMLDocument *)document {
    if (self = [super init]) {
        [self initEnv];
        self.xmlDocument = document;
    }
    
    return self;
}

- (void) initEnv {
    self.fieldsDict = [[NSMutableDictionary alloc] init];
    self.xpathMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     @"/a:entry/a:contributor/snx:userid", @"userid",
                     @"/a:entry/a:contributor/a:name", @"name",
                     @"/a:entry/a:contributor/a:email", @"email",
                     @"/a:entry/snx:role", @"role",
                     nil];
}

- (NSString *)userId {
    if (_userId == nil) {
        _userId = [self getFieldWithXPath:@"userid"];
    }
    
    return _userId;
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    [self.fieldsDict setValue:userId forKey:@"userid"];
}

- (NSString *)email {
    if (_email == nil) {
        _email = [self getFieldWithXPath:@"email"];
    }
    
    return _email;
}

- (void)setEmail:(NSString *)email {
    _email = email;
    [self.fieldsDict setValue:email forKey:@"email"];
}

- (NSString *)name {
    if (_name == nil) {
        _name = [self getFieldWithXPath:@"name"];
    }
    
    return _name;
}

- (void)setName:(NSString *)name {
    _name = name;
    [self.fieldsDict setValue:name forKey:@"name"];
}

- (NSString *)role {
    if (_role == nil) {
        _role = [self getFieldWithXPath:@"role"];
    }
    
    return _role;
}

- (void)setRole:(NSString *)role {
    _role = role;
    [self.fieldsDict setValue:role forKey:@"role"];
}

- (id) getFieldWithXPath:(NSString *) fieldName {
    
    NSError *error;
    NSDictionary *dict = [SBTCommunityMember namespacesForCommunityMember];
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

+ (NSDictionary *) namespacesForCommunityMember {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"http://www.ibm.com/xmlns/prod/sn" forKey:@"snx"];
    [dict setValue:@"http://www.w3.org/2005/Atom" forKey:@"a"];
    
    return dict;
}

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"User id: %@\n", self.userId];
    description = [description stringByAppendingFormat:@"Name: %@\n", self.name];
    description = [description stringByAppendingFormat:@"Email: %@\n", self.email];
    
    return description;
}


- (NSString *) constructRequestBody {
    NSString *requestBody = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:app=\"http://www.w3.org/2007/app\" xmlns:snx=\"http://www.ibm.com/xmlns/prod/sn\"><contributor>";
    
    if ([SBTUtils isEmail:self.userId]) {
        requestBody = [requestBody stringByAppendingFormat:@"<email>%@</email>", self.userId];
    } else {
        requestBody = [requestBody stringByAppendingFormat:@"<snx:userid>%@</snx:userid>", self.userId];
    }
    
    requestBody = [requestBody stringByAppendingFormat:@"</contributor>"];
    
    if (self.role != nil) {
        requestBody = [requestBody stringByAppendingFormat:@"<snx:role component=\"http://www.ibm.com/xmlns/prod/sn/communities\">%@</snx:role>", self.role];
    }
    
    requestBody = [requestBody stringByAppendingString:@"</entry>"];
    
    return requestBody;
}

@end
