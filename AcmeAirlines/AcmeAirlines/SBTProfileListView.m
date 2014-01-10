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

//  This class is a generic class to show list of people in a table view.
//  Tapping a row will take to a new full profile view of that person.

#import "SBTProfileListView.h"
#import <iOSSBTK/SBTConnectionsProfile.h>
#import "SBTAcmeConstant.h"
#import "SBTAcmeMyProfileView.h"
#import "SBTAcmeUtils.h"

@interface SBTProfileListView ()

@end

@implementation SBTProfileListView

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
    return [self.listOfProfiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTConnectionsProfile *profile = [self.listOfProfiles objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        // Profile photo view
        CGRect photoFrame;
        float imageSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            photoFrame = CGRectMake(5, 5, 60, 60);
            imageSize = 60;
        } else {
            photoFrame = CGRectMake(5, 5, 40, 40);
            imageSize = 40;
        }
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 1;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Name label
        CGRect nameFrame;
        float textSize;
        float height;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textSize = TEXT_SIZE_IPAD;
            nameFrame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 20, 5, 400, 30);
            height = 30;
        } else {
            textSize = TEXT_SIZE;
            nameFrame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 20, 5, 200, 20);
            height = 20;
        }
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:textSize];
        nameLabel.tag = 2;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Title label
        CGRect titleFrame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            titleFrame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height, 400, 30);
        } else {
            titleFrame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height, 200, 20);
        }
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
        titleLabel.tag = 3;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Add them to the content
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:titleLabel];
        
        
        // ImageView label constraints
        NSLayoutConstraint *constraintImageViewHeight = [NSLayoutConstraint constraintWithItem:imageView
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1
                                                                                 constant:imageSize];
        NSLayoutConstraint *constraintImageViewWidth = [NSLayoutConstraint constraintWithItem:imageView
                                                                                     attribute:NSLayoutAttributeWidth
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:nil
                                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                                    multiplier:1
                                                                                      constant:imageSize];
        NSLayoutConstraint *constraintImageViewLeft = [NSLayoutConstraint constraintWithItem:imageView
                                                                              attribute:NSLayoutAttributeLeft
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:cell.contentView
                                                                              attribute:NSLayoutAttributeLeft
                                                                             multiplier:1
                                                                               constant:5];
        NSLayoutConstraint *constraintImageViewTop = [NSLayoutConstraint constraintWithItem:imageView
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:cell.contentView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:5];
        [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintImageViewHeight, constraintImageViewWidth, constraintImageViewLeft, constraintImageViewTop, nil]];
        
        // Name label constraints
        NSLayoutConstraint *constraintNameHeight = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:height];
        NSLayoutConstraint *constraintNameTop = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:imageView
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1
                                                                               constant:0];
        NSLayoutConstraint *constraintNameLeft = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:imageView
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1
                                                                           constant:20];
        NSLayoutConstraint *constraintNameRight = [NSLayoutConstraint constraintWithItem:nameLabel
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:cell.contentView
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1
                                                                            constant:-30];
        [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintNameHeight, constraintNameTop, constraintNameLeft, constraintNameRight, nil]];
        
        // Title label constraints
        NSLayoutConstraint *constraintTitleHeight = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:height];
        NSLayoutConstraint *constraintTitleTop = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nameLabel
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1
                                                                                constant:0];
        NSLayoutConstraint *constraintTitleLeft = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nameLabel
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1
                                                                           constant:0];
        NSLayoutConstraint *constraintTitleRight = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nameLabel
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1
                                                                            constant:0];
        [cell.contentView addConstraints:[NSArray arrayWithObjects:constraintTitleHeight, constraintTitleTop, constraintTitleLeft, constraintTitleRight, nil]];
        
    }
    
    UIImageView *imageView = (UIImageView *) [cell.contentView viewWithTag:1];
    UILabel *nameLabel = (UILabel *) [cell.contentView viewWithTag:2];
    UILabel *titleLabel = (UILabel *) [cell.contentView viewWithTag:3];
    
    nameLabel.text = profile.displayName;
    titleLabel.text = profile.title;
    
    // Download and set the profile photo
    NSString *urlStr;
    if (profile.thumbnailURL == nil) {
        urlStr = [NSString stringWithFormat:@"%@/profiles/photo.do?userid=%@", [SBTUtils getUrlForEndPoint:@"connections"], profile.userId];
    } else {
        urlStr = profile.thumbnailURL;
    }
    
    [SBTAcmeUtils downloadAndSetImage:imageView url:urlStr];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 70;
    else
        return 50;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTConnectionsProfile *profile = [self.listOfProfiles objectAtIndex:indexPath.row];
    SBTAcmeMyProfileView *profileView = [[SBTAcmeMyProfileView alloc] init];
    profileView.myProfile = profile;
    [self.navigationController pushViewController:profileView animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
