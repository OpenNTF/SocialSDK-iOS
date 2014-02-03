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

//  This class is a generic webview. Before pushing or presenting it, a link needs to be set

#import "SBTAcmeWebView.h"
#import <iOSSBTK/FBLog.h>
#import "SBTAcmeConstant.h"

@interface SBTAcmeWebView ()

@end

@implementation SBTAcmeWebView

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
    
    UIBarButtonItem *processing = [[UIBarButtonItem alloc] initWithCustomView:self.actIndicator];
    self.navigationItem.rightBarButtonItem = processing;
    self.toolBar.tintColor = [UIColor colorWithRed:90.0/255
                                             green:91.0/255
                                              blue:71.0/255
                                             alpha:1];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSURL *url;
    if ([self.link rangeOfString:@"http"].location != NSNotFound) {
        url = [NSURL URLWithString:self.link];
    } else {
        url = [NSURL fileURLWithPath:self.link];
    }
    
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:request];
	self.webView.scalesPageToFit = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *loadingLabel = NSLocalizedStringWithDefaultValue(@"LOADING",
                              @"Common",
                              [NSBundle mainBundle],
                              @"Loading...",
                              @"Loading common label");
    self.title = loadingLabel;
	[self.actIndicator startAnimating];
    
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.actIndicator stopAnimating];
    self.title = @"";
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (IS_DEBUGGING)
        [FBLog log:[NSString stringWithFormat:@"Error : %@", error] from:self];
    [self.actIndicator stopAnimating];
}

@end
