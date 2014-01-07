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

#import "SBTAcmeBookmarksView.h"
#import "FBLog.h"
#import "SBTAcmeUtils.h"
#import "SBTAcmeWebView.h"

@interface SBTAcmeBookmarksView ()

@property (strong, nonatomic) NSMutableArray *listOfBookmarks;

@end

@implementation SBTAcmeBookmarksView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.listOfBookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    IBMCommunityBookmark *bookmark = [self.listOfBookmarks objectAtIndex:indexPath.row];
    cell.textLabel.text = bookmark.title;
    cell.detailTextLabel.text = bookmark.summary;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IBMCommunityBookmark *bookmark = [self.listOfBookmarks objectAtIndex:indexPath.row];
    SBTAcmeWebView *webView = [[SBTAcmeWebView alloc] init];
    webView.link = bookmark.bUrl;
    [self.navigationController pushViewController:webView animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helper methods

- (void) getBookmarksWithCompletionHandler:(void (^)(BOOL)) completionHandler {
    IBMConnectionsCommunityService *commService = [[IBMConnectionsCommunityService alloc] init];
    [commService getBookmarksForCommunity:self.community
                                  success:^(NSMutableArray *list) {
                                      self.listOfBookmarks = list;
                                      completionHandler(YES);
                                  } failure:^(NSError *error) {
                                      if (IS_DEBUGGING)
                                          [FBLog log:[error description] from:self];
                                      
                                      completionHandler(NO);
                                  }];
}

@end
