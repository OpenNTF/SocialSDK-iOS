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

#import "SBTActivityStreamAttachment.h"

@implementation SBTActivityStreamAttachment

- (NSString *) description {
    
    NSString *description = @"\n";
    description = [description stringByAppendingFormat:@"Attachment id: %@\n", self.aId];
    description = [description stringByAppendingFormat:@"Name: %@\n", self.displayName];
    description = [description stringByAppendingFormat:@"isImage: %@\n", [self.isImage description]];
    description = [description stringByAppendingFormat:@"Summary: %@\n", self.summary];
    description = [description stringByAppendingFormat:@"Author: %@\n", [self.author description]];
    description = [description stringByAppendingFormat:@"Published: %@\n", self.published];
    description = [description stringByAppendingFormat:@"Url: %@\n", self.url];
    description = [description stringByAppendingFormat:@"Image url: %@\n", self.imageUrl];
    
    return description;
}

@end
