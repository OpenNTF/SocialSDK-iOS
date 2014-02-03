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

//   This class list and handles my booked flights

#import "SBTAcmeMyFlightView.h"
#import "SBTAcmeConstant.h"
#import "SBTAcmeFlight.h"
#import "SBTAcmeUtils.h"
#import <iOSSBTK/SBTHttpClient.h>
#import <iOSSBTK/FBLog.h>

@interface SBTAcmeMyFlightView ()

@end

@implementation SBTAcmeMyFlightView

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
    NSString *myFlights = NSLocalizedStringWithDefaultValue(@"MY_FLIGHTS",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"My Flights",
                                  @"My Flights");
    [super viewDidLoad];
    
    self.title = myFlights;
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getRequestStatusFromAcme)];
    self.navigationItem.rightBarButtonItem = refreshItem;

    [self getRequestStatusFromAcme];
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
    return [self.listOfMyFlights count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTAcmeFlight *flight = [self.listOfMyFlights objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubViewsToCell:cell indexPath:indexPath];
    }
    
    UILabel *flightNumberLabel = (UILabel *) [cell.contentView viewWithTag:100];
    UILabel *approvalLabel = (UILabel *) [cell.contentView viewWithTag:200];
    UILabel *statusLabel = (UILabel *) [cell.contentView viewWithTag:300];
    UIButton *checkinButton = (UIButton *) [cell.contentView viewWithTag:(400 + indexPath.row)];
    
    flightNumberLabel.text = flight.flightId;
    approvalLabel.text = flight.approver;
    statusLabel.text = flight.status;
    if ([flight.status isEqualToString:@"approved"]) {
        statusLabel.textColor = [UIColor greenColor];
        checkinButton.enabled = YES;
        [checkinButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    } else if ([flight.status isEqualToString:@"started"]) {
        statusLabel.textColor = [UIColor colorWithRed:238/255.0 green:173/255.0 blue:14/255.0 alpha:1];
        checkinButton.enabled = NO;
        [checkinButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    } else if ([flight.status isEqualToString:@"denied"]) {
        statusLabel.textColor = [UIColor redColor];
        checkinButton.enabled = NO;
        [checkinButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 110;
    else
        return 70;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Helper methods

/**
 This method is called when user taps the checkin button
 @param sender: UIButton to retreive which button is tapped
 */
- (void) checkedIn:(UIButton *) sender {
    //NSInteger index = sender.tag - 400;
    
    NSString *congrats = NSLocalizedStringWithDefaultValue(@"CONGRATS",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Congrats!",
                                  @"Congrats!");
    NSString *checkinSuccessful = NSLocalizedStringWithDefaultValue(@"CHECKIN_SUCCESSFUL",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"You successfully checked-in",
                                  @"You successfully checked-in");
    NSString *okLabel = NSLocalizedStringWithDefaultValue(@"OK",
                              @"Common",
                              [NSBundle mainBundle],
                              @"OK",
                              @"OK Common label");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:congrats
                                                        message:checkinSuccessful
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:okLabel, nil];
    [alertView show];
}

/**
 This methods gets my booked flights along with the status of approval
 */
- (void) getRequestStatusFromAcme {
    
    if (self.myProfile == nil)
        return;
    
    SBTHttpClient *httpClient = [[SBTHttpClient alloc] initWithBaseURL:
                                 [NSURL URLWithString:[SBTAcmeUtils getAcmeUrl]]];
    
    NSString *path = [NSString stringWithFormat:@"/acme.social.sample.dataapp/rest/flights/%@/lists",
                      self.myProfile.email];
    [httpClient getPath:path
             parameters:nil
                success:^(id response, id result) {
                    NSError *error = nil;
                    NSMutableArray *resultJson = [NSJSONSerialization JSONObjectWithData:result
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&error];
                    if (error == nil) {
                        if (resultJson != nil && [resultJson count] > 0) {
                            NSMutableArray *newList = [[NSMutableArray alloc] init];
                            for (NSDictionary *entry in resultJson) {
                                SBTAcmeFlight *flight = [[SBTAcmeFlight alloc] init];
                                flight.flightId = [entry objectForKey:@"FlightId"];
                                flight.status = [entry objectForKey:@"state"];
                                flight.approver = [entry objectForKey:@"ApproverId"];
                                
                                [newList addObject:flight];
                            }
                            
                            self.listOfMyFlights = newList;
                            [self.tableView reloadData];
                        }
                    } else {
                        if (IS_DEBUGGING)
                            [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                    }
                } failure:^(id response, NSError *error) {
                    if (IS_DEBUGGING)
                        [FBLog log:[NSString stringWithFormat:@"%@", [error description]] from:self];
                }];
}

/**
 This method adds all subviews to the cell
 */
- (void) addSubViewsToCell:(UITableViewCell *) cell indexPath:(NSIndexPath *) indexPath {
    
    NSString *flightText = NSLocalizedStringWithDefaultValue(@"FLIGHT",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Flight",
                                  @"Flight label");
    NSString *approverText = NSLocalizedStringWithDefaultValue(@"APPROVE",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Approver",
                                  @"Approver label");
    NSString *statusText = NSLocalizedStringWithDefaultValue(@"STATUS",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Status",
                                  @"Status label");
    NSString *checkinText = NSLocalizedStringWithDefaultValue(@"CHECKIN",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Checkin",
                                  @"Checkin label");
    CGRect frame;
    float textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textSize = TEXT_SIZE_IPAD_SMALL;
        frame = CGRectMake(10, 5, 100, 45);
    } else {
        textSize = TEXT_SIZE_SMALL;
        frame = CGRectMake(7, 5, 50, 30);
    }
    UILabel *flightNumberTitleLabel = [[UILabel alloc] initWithFrame:frame];
    flightNumberTitleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    flightNumberTitleLabel.text = flightText;
    flightNumberTitleLabel.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(flightNumberTitleLabel.frame.origin.x + flightNumberTitleLabel.frame.size.width + 5, flightNumberTitleLabel.frame.origin.y, 200, 45);
    } else {
        frame = CGRectMake(flightNumberTitleLabel.frame.origin.x + flightNumberTitleLabel.frame.size.width + 3, flightNumberTitleLabel.frame.origin.y, 100, 30);
    }
    UILabel *approverTitleLabel = [[UILabel alloc] initWithFrame:frame];
    approverTitleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    approverTitleLabel.text = approverText;
    approverTitleLabel.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(approverTitleLabel.frame.origin.x + approverTitleLabel.frame.size.width + 10, approverTitleLabel.frame.origin.y, 120, 45);
    } else {
        frame = CGRectMake(approverTitleLabel.frame.origin.x + approverTitleLabel.frame.size.width + 10, approverTitleLabel.frame.origin.y, 65, 30);
    }
    UILabel *statusTitleLabel = [[UILabel alloc] initWithFrame:frame];
    statusTitleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    statusTitleLabel.textColor = [UIColor blackColor];
    statusTitleLabel.text = statusText;
    statusTitleLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *flightNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(flightNumberTitleLabel.frame.origin.x, flightNumberTitleLabel.frame.origin.y + flightNumberTitleLabel.frame.size.height, flightNumberTitleLabel.frame.size.width, flightNumberTitleLabel.frame.size.height)];
    flightNumberLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    flightNumberLabel.tag = 100;
    flightNumberLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *approvalLabel = [[UILabel alloc] initWithFrame:CGRectMake(approverTitleLabel.frame.origin.x, approverTitleLabel.frame.origin.y + approverTitleLabel.frame.size.height, approverTitleLabel.frame.size.width, approverTitleLabel.frame.size.height)];
    approvalLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    approvalLabel.adjustsFontSizeToFitWidth = YES;
    approvalLabel.tag = 200;
    approvalLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(statusTitleLabel.frame.origin.x, statusTitleLabel.frame.origin.y + statusTitleLabel.frame.size.height, statusTitleLabel.frame.size.width, statusTitleLabel.frame.size.height)];
    statusLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    statusLabel.adjustsFontSizeToFitWidth = YES;
    statusLabel.tag = 300;
    statusLabel.backgroundColor = [UIColor clearColor];
    
    // Checkin button
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(statusTitleLabel.frame.origin.x + statusTitleLabel.frame.size.width, 55-45/2, 90, 45);
    } else {
        frame = CGRectMake(statusTitleLabel.frame.origin.x + statusTitleLabel.frame.size.width, 35-15, 60, 30);
    }
    UIButton *checkinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    checkinButton.frame = frame;
    checkinButton.titleLabel.font = [UIFont boldSystemFontOfSize:textSize-1];
    [checkinButton setTitle:checkinText forState:UIControlStateNormal];
    [checkinButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [checkinButton addTarget:self action:@selector(checkedIn:) forControlEvents:UIControlEventTouchUpInside];
    checkinButton.tag = 400 + indexPath.row;
    
    
    [cell.contentView addSubview:flightNumberTitleLabel];
    [cell.contentView addSubview:approverTitleLabel];
    [cell.contentView addSubview:statusTitleLabel];
    [cell.contentView addSubview:flightNumberLabel];
    [cell.contentView addSubview:approvalLabel];
    [cell.contentView addSubview:statusLabel];
    [cell.contentView addSubview:checkinButton];
}

@end
