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

#import "IBMFilePersonEntry.h"
#import "IBMConstants.h"
#import "FBLog.h"

@interface IBMFilePersonEntry ()

@property (strong, nonatomic) NSMutableDictionary *xpathMap;

@end

@implementation IBMFilePersonEntry

@synthesize name = _name, email = _email, userState = _userState, userUuid = _userUuid;

FP_USER_TYPE type;

- (id) init {
    if (self = [super init]) {
        [self initEnv];
    }
    
    return self;
}

- (id) initWithXMLDocument:(IBMXMLDocument *)document userType:(FP_USER_TYPE) type_ {
    if (self = [super init]) {
        [self initEnv];
        self.xmlDocument = document;
        type = type_;
    }
    
    return self;
}

- (void) initEnv {
    //self.fieldsDict = [[NSMutableDictionary alloc] init];
    self.xpathMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     @"/a:entry/a:author/a:email", @"emailFromEntry",
                     @"/a:entry/a:author/snx:userid", @"userUuidFromEntry",
                     @"/a:entry/a:author/a:name", @"nameOfUserFromEntry",
                     @"/a:entry/a:author/snx:userState", @"userStateFromEntry",
                     @"/a:entry/td:modifier/snx:userState", @"userStateModifier",
                     @"/a:entry/td:modifier/a:name", @"nameModifier",
                     @"/a:entry/td:modifier/snx:userid", @"userUuidModifier",
                     @"/a:entry/td:modifier/a:email", @"emailModifier",
                     nil];
}

- (NSString *)name {
    if (_name == nil) {
        if (type == FP_AUTHOR)
            _name = [self getFieldWithXPath:@"nameOfUserFromEntry"];
        else
            _name = [self getFieldWithXPath:@"nameModifier"];
    }
    
    return _name;
}

- (NSString *)email {
    if (_email == nil) {
        if (type == FP_AUTHOR)
            _email = [self getFieldWithXPath:@"emailFromEntry"];
        else
            _email = [self getFieldWithXPath:@"emailModifier"];
    }
    
    return _email;
}

- (NSString *)userState {
    if (_userState == nil) {
        if (type == FP_AUTHOR)
            _userState = [self getFieldWithXPath:@"userStateFromEntry"];
        else
            _userState = [self getFieldWithXPath:@"userStateModifier"];
    }
    
    return _userState;
}

- (NSString *)userUuid {
    if (_userUuid == nil) {
        if (type == FP_AUTHOR)
            _userUuid = [self getFieldWithXPath:@"userUuidFromEntry"];
        else
            _userUuid = [self getFieldWithXPath:@"userUuidModifier"];
    }
    
    return _userUuid;
}

- (id) getFieldWithXPath:(NSString *) fieldName {
    
    NSError *error;
    NSDictionary *dict = [IBMFilePersonEntry namespacesForPersonEntry];
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

+ (NSDictionary *) namespacesForPersonEntry {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"http://www.ibm.com/xmlns/prod/sn" forKey:@"snx"];
    [dict setValue:@"http://www.w3.org/2005/Atom" forKey:@"a"];
    [dict setValue:@"urn:ibm.com/td" forKey:@"td"];
    [dict setValue:@"http://a9.com/-/spec/opensearch/1.1/" forKey:@"opensearch"];
    
    return dict;
}

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"Name: %@\n", self.name];
    description = [description stringByAppendingFormat:@"Email: %@\n", self.email];
    description = [description stringByAppendingFormat:@"User state: %@\n", self.userState];
    description = [description stringByAppendingFormat:@"User uuid: %@\n", self.userUuid];
    
    return description;
}

@end
