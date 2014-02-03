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

//  This class list the flight status read from a static file

#import "SBTAcmeFlightStatusView.h"
#import "SBTAcmeConstant.h"
#import "SBTAcmeFlight.h"

@interface SBTAcmeFlightStatusView ()

@end

@implementation SBTAcmeFlightStatusView

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

    NSString *flightStatusLabel = NSLocalizedStringWithDefaultValue(@"FLIGHT_STATUS",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Flight Status",
                                  @"Flight Status");
    self.title = flightStatusLabel;
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
    return [self.listOfFlights count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTAcmeFlight *flight = [self.listOfFlights objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubViewsToCell:cell];
    }
    
    
    UILabel *flightNumberLabel = (UILabel *) [cell.contentView viewWithTag:100];
    UILabel *departLabel = (UILabel *) [cell.contentView viewWithTag:200];
    UILabel *arriveLabel = (UILabel *) [cell.contentView viewWithTag:300];
    UILabel *stateLabel = (UILabel *) [cell.contentView viewWithTag:400];
    
    flightNumberLabel.text = flight.flightId;
    departLabel.text = [[self.airportCodes valueForKey:flight.departureCity] valueForKey:@"city"];
    arriveLabel.text = [[self.airportCodes valueForKey:flight.arrivalCity] valueForKey:@"city"];
    NSString *state = [self.flightStatus objectForKey:flight.flightId];
    stateLabel.text = state;
    if ([state isEqualToString:@"DELAYED"] || [state isEqualToString:@"LATE"])
        stateLabel.textColor = [UIColor colorWithRed:238/255.0 green:173/255.0 blue:14/255.0 alpha:1];
    else if ([state isEqualToString:@"ONTIME"] || [state isEqualToString:@"INFLIGHT"])
        stateLabel.textColor = [UIColor greenColor];
    else if ([state isEqualToString:@"CANCELED"])
        stateLabel.textColor = [UIColor redColor];
                       
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 100;
    else
        return 70;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/**
 Add all subviews to the cell
 */
- (void) addSubViewsToCell:(UITableViewCell *) cell {
    
    NSString *flightText = NSLocalizedStringWithDefaultValue(@"FLIGHT",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Flight",
                                  @"Flight label");
    NSString *departText = NSLocalizedStringWithDefaultValue(@"DEPART",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Depart",
                                  @"Depart label");
    NSString *arriveText = NSLocalizedStringWithDefaultValue(@"ARRIVE",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"Arrive",
                                  @"Arrive label");
    NSString *stateText = NSLocalizedStringWithDefaultValue(@"STATE",
                                  nil,
                                  [NSBundle mainBundle],
                                  @"State",
                                  @"State label");
    CGRect frame;
    float textSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textSize = TEXT_SIZE_IPAD_SMALL;
        frame = CGRectMake(10, 5, 100, 45);
    } else {
        textSize = TEXT_SIZE_SMALL;
        frame = CGRectMake(10, 5, 50, 30);
    }
    UILabel *flightNumberTitleLabel = [[UILabel alloc] initWithFrame:frame];
    flightNumberTitleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    flightNumberTitleLabel.text = flightText;
    flightNumberTitleLabel.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(flightNumberTitleLabel.frame.origin.x + flightNumberTitleLabel.frame.size.width + 10, flightNumberTitleLabel.frame.origin.y, 180, flightNumberTitleLabel.frame.size.height);
    } else {
        frame = CGRectMake(flightNumberTitleLabel.frame.origin.x + flightNumberTitleLabel.frame.size.width + 3, flightNumberTitleLabel.frame.origin.y, 90, flightNumberTitleLabel.frame.size.height);
    }
    UILabel *departTitleLabel = [[UILabel alloc] initWithFrame:frame];
    departTitleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    departTitleLabel.text = departText;
    departTitleLabel.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(departTitleLabel.frame.origin.x + departTitleLabel.frame.size.width + 10, departTitleLabel.frame.origin.y, 150, departTitleLabel.frame.size.height);
    } else {
        frame = CGRectMake(departTitleLabel.frame.origin.x + departTitleLabel.frame.size.width + 3, departTitleLabel.frame.origin.y, 75, departTitleLabel.frame.size.height);
    }
    UILabel *arriveTitleLabel = [[UILabel alloc] initWithFrame:frame];
    arriveTitleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    arriveTitleLabel.text = arriveText;
    arriveTitleLabel.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(arriveTitleLabel.frame.origin.x + arriveTitleLabel.frame.size.width + 10, arriveTitleLabel.frame.origin.y, 140, arriveTitleLabel.frame.size.height);
    } else {
        frame = CGRectMake(arriveTitleLabel.frame.origin.x + arriveTitleLabel.frame.size.width + 5, arriveTitleLabel.frame.origin.y, 60, arriveTitleLabel.frame.size.height);
    }
    UILabel *stateTitleLabel = [[UILabel alloc] initWithFrame:frame];
    stateTitleLabel.font = [UIFont boldSystemFontOfSize:textSize];
    stateTitleLabel.text = stateText;
    stateTitleLabel.backgroundColor = [UIColor clearColor];
    
    // Dynamic fields
    UILabel *flightNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(flightNumberTitleLabel.frame.origin.x, flightNumberTitleLabel.frame.origin.y + flightNumberTitleLabel.frame.size.height, flightNumberTitleLabel.frame.size.width, flightNumberTitleLabel.frame.size.height)];
    flightNumberLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    flightNumberLabel.tag = 100;
    flightNumberLabel.backgroundColor = [UIColor clearColor];
    
    
    UILabel *departLabel = [[UILabel alloc] initWithFrame:CGRectMake(departTitleLabel.frame.origin.x, departTitleLabel.frame.origin.y +  + departTitleLabel.frame.size.height, departTitleLabel.frame.size.width, departTitleLabel.frame.size.height)];
    departLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    departLabel.tag = 200;
    departLabel.backgroundColor = [UIColor clearColor];
    departLabel.adjustsFontSizeToFitWidth = YES;
    
    
    UILabel *arriveLabel = [[UILabel alloc] initWithFrame:CGRectMake(arriveTitleLabel.frame.origin.x, arriveTitleLabel.frame.origin.y +  + arriveTitleLabel.frame.size.height, arriveTitleLabel.frame.size.width, arriveTitleLabel.frame.size.height)];
    arriveLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize];
    arriveLabel.tag = 300;
    arriveLabel.backgroundColor = [UIColor clearColor];
    arriveLabel.adjustsFontSizeToFitWidth = YES;
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(stateTitleLabel.frame.origin.x, stateTitleLabel.frame.origin.y +  + stateTitleLabel.frame.size.height, stateTitleLabel.frame.size.width, stateTitleLabel.frame.size.height)];
    stateLabel.font = [UIFont fontWithName:TEXT_FONT size:textSize-2];
    stateLabel.tag = 400;
    stateLabel.backgroundColor = [UIColor clearColor];
    stateLabel.adjustsFontSizeToFitWidth = YES;
    
    [cell.contentView addSubview:flightNumberTitleLabel];
    [cell.contentView addSubview:departTitleLabel];
    [cell.contentView addSubview:arriveTitleLabel];
    [cell.contentView addSubview:stateTitleLabel];
    
    [cell.contentView addSubview:flightNumberLabel];
    [cell.contentView addSubview:departLabel];
    [cell.contentView addSubview:arriveLabel];
    [cell.contentView addSubview:stateLabel];
}

@end
