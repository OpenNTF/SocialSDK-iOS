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

// This class is a wrapper to the xml parser we're using. It is used to abstract the xml parser we're using.
// Currently we're using Google's objective-c xml parser.

#import "GDataXMLNode.h"

@interface SBTXMLDocument : GDataXMLDocument

#pragma mark - properties

@property (strong, nonatomic) NSDictionary *namespaces;

#pragma mark - methods



@end
