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

//  Controller to manage login

#import "LoginView.h"
#import "SBTAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <iOSSBTK/SBTCredentialStore.h>
#import <iOSSBTK/SBTConstants.h>
#import "SBTAcmeConstant.h"
#import <iOSSBTK/SBTHttpClient.h>
#import <iOSSBTK/FBLog.h>
#import <iOSSBTK/SBTConnectionsOAuth2EndPoint.h>
#import <iOSSBTK/SBTConnectionsBasicEndPoint.h>

@interface LoginView ()

@end

@implementation LoginView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.smartCloudTitle.text = @"Acme Airlines";
    self.connectionsUrlField.placeholder = @"Connections server url";
    self.acmeUrlField.placeholder = @"Acme server url";
    self.userNameField.placeholder = @"Username";
    self.passwordField.placeholder = @"Password";
    
    self.loginButton.layer.masksToBounds = YES;
	self.loginButton.layer.cornerRadius = 5;
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    
    NSString *connectionsUrl = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_CONNECTIONS_URL];
    NSString *acmeUrl = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_ACME_URL];
    
    if (connectionsUrl.length > 0)
        self.connectionsUrlField.text = connectionsUrl;
    if (acmeUrl.length > 0)
        self.acmeUrlField.text = acmeUrl;
    
    NSString *username = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_USERNAME];
    NSString *password = [SBTCredentialStore loadWithKey:IBM_CREDENTIAL_PASSWORD];
    
    if (username.length > 0)
        self.userNameField.text = username;
    if (password.length > 0)
        self.passwordField.text = password;
    
    if (connectionsUrl.length > 0 && acmeUrl.length > 0 && username.length > 0 && password.length > 0) {
        [self login:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 3) {
        [self.acmeUrlField becomeFirstResponder];
    } else if (textField.tag == 4) {
        [self.userNameField becomeFirstResponder];
    } else if (textField.tag == 1) {
        [self.passwordField becomeFirstResponder];
    } else {
        // Password
        [self login:nil];
    }
    return YES;
}

- (IBAction)login:(id)sender {
    
    if (self.connectionsUrlField.text.length == 0 || self.acmeUrlField.text.length == 0 || self.userNameField.text.length == 0 || self.passwordField.text.length == 0 ) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"None of the fields can be empty!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        
        return;
    }
    
    [SBTCredentialStore storeWithKey:IBM_CREDENTIAL_CONNECTIONS_URL value:self.connectionsUrlField.text];
    [SBTCredentialStore storeWithKey:IBM_CREDENTIAL_ACME_URL value:self.acmeUrlField.text];

    [self.actIndicator startAnimating];
    [self.loginButton setTitle:@"Loging in..." forState:UIControlStateNormal];
    self.loginButton.enabled = NO;
    self.userNameField.userInteractionEnabled = NO;
    self.passwordField.userInteractionEnabled = NO;
    
    
    SBTConnectionsBasicEndPoint *endPoint = (SBTConnectionsBasicEndPoint *) [SBTEndPoint findEndPoint:@"connections"];
    [endPoint authenticateWithUsername:self.userNameField.text
                              password:self.passwordField.text
                     completionHandler:^(NSError *error) {
                         if (error == nil) {
                             [self.actIndicator stopAnimating];
                             [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
                             self.loginButton.enabled = YES;
                             
                             self.connectionsUrlField.userInteractionEnabled = YES;
                             self.acmeUrlField.userInteractionEnabled = YES;
                             self.userNameField.userInteractionEnabled = YES;
                             self.passwordField.userInteractionEnabled = YES;
                             [self dismissViewControllerAnimated:YES completion:^(void) {
                                 
                             }];
                         } else {
                             NSLog(@"%@", [error description]);
                             [FBLog log:[error description] from:self];
                             
                             [self.actIndicator stopAnimating];
                             [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
                             self.loginButton.enabled = YES;
                             
                             self.connectionsUrlField.userInteractionEnabled = YES;
                             self.acmeUrlField.userInteractionEnabled = YES;
                             self.userNameField.userInteractionEnabled = YES;
                             self.passwordField.userInteractionEnabled = YES;
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connections url, username or password is wrong!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                             [alert show];
                         }
                     }];    
}

@end
