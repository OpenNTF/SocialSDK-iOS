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

//  This class log the flow and the unexpected errors to the file ("fb_log") at the document directory

#import "FBLog.h"

@implementation FBLog

+ (NSString *) getFilePath {
    NSString *logFileName = @"fb_log";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:logFileName];
}

+ (void) createLogFile {
    NSString *filePath = [self getFilePath];
    NSLog(@"Logging at: %@", filePath);
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filePath contents:[NSData data] attributes:nil];
}

+ (void) log:(NSString *) str from:(id) class {
    
    if (str == nil)
        return;
    else {
        str = [[[NSDate date] description] stringByAppendingFormat:@"\t%@\t%@\n",[[class class] description], str];
    }
    
    NSString *filePath = [self getFilePath];
    NSFileHandle *fHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [fHandle seekToEndOfFile];
    [fHandle writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
