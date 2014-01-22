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
//  This class represent the comment object of File

#import "SBTFileCommentEntry.h"
#import "SBTConstants.h"
#import "FBLog.h"

@interface SBTFileCommentEntry ()

@property (strong, nonatomic) NSMutableDictionary *xpathMap;

@end

@implementation SBTFileCommentEntry

@synthesize commentId = _commentId, comment = _comment, personEntry = _personEntry, modifier = _modifier;

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
    //self.fieldsDict = [[NSMutableDictionary alloc] init];
    self.xpathMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     @"/a:entry/a:content", @"commentFromEntry",
                     @"/a:entry/td:uuid", @"uuidFromEntry",
                     @"/a:entry/a:category/@label", @"categoryFromEntry",
                     nil];
}

- (NSString *)commentId {
    if (_commentId == nil) {
        if (![[self getFieldWithXPath:@"categoryFromEntry"] isEqualToString:@"comment"]) {
            return nil;
        }
        
        _commentId = [self getFieldWithXPath:@"uuidFromEntry"];
    }
    
    return _commentId;
}

- (NSString *)comment {
    if (_comment == nil) {
        if (![[self getFieldWithXPath:@"categoryFromEntry"] isEqualToString:@"comment"]) {
            return nil;
        }
        
        _comment = [self getFieldWithXPath:@"commentFromEntry"];
    }
    
    return _comment;
}

- (SBTFilePersonEntry *)personEntry {
    if (_personEntry == nil) {
        _personEntry = [[SBTFilePersonEntry alloc] initWithXMLDocument:self.xmlDocument userType:FP_AUTHOR];
    }
    
    return _personEntry;
}

- (SBTFilePersonEntry *)modifier {
    if (_modifier == nil) {
        _modifier = [[SBTFilePersonEntry alloc] initWithXMLDocument:self.xmlDocument userType:FP_MODIFIER];
    }
    
    return _modifier;
}


- (id) getFieldWithXPath:(NSString *) fieldName {
    
    NSError *error;
    NSDictionary *dict = [SBTFileCommentEntry namespacesForCommentEntry];
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

+ (NSDictionary *) namespacesForCommentEntry {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"http://www.ibm.com/xmlns/prod/sn" forKey:@"snx"];
    [dict setValue:@"http://www.w3.org/2005/Atom" forKey:@"a"];
    [dict setValue:@"urn:ibm.com/td" forKey:@"td"];
    [dict setValue:@"http://a9.com/-/spec/opensearch/1.1/" forKey:@"opensearch"];
    
    return dict;
}

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"Comment id: %@\n", self.commentId];
    description = [description stringByAppendingFormat:@"Comment: %@\n", self.comment];
    description = [description stringByAppendingFormat:@"Person: %@\n", [self.personEntry description]];
    description = [description stringByAppendingFormat:@"Modifier: %@\n", [self.modifier description]];
    
    return description;
}

@end
