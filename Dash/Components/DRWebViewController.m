//
//  DRWebViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/30/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRWebViewController.h"

@interface DRWebViewController ()
@property (strong, nonatomic) NSURL *url;
@end

@implementation DRWebViewController

+ (instancetype)webViewWithUrl:(NSURL *)url
{
    DRWebViewController *wvc = [[DRWebViewController alloc] initWithNibName:@"DRWebViewController" bundle:nil];
    wvc.url = url;
    return wvc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView.allowsInlineMediaPlayback = IS_IPAD;
    
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
        NSLog(@"Loading URL: %@", self.url.absoluteString);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    NSLog(@"Loading %@", webView.request);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Loaded %@", webView.request);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Load failed with error:\n%@", error);
    if ([error code] != NSURLErrorCancelled) {
        [[[UIAlertView alloc] initWithTitle:@"Load Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    }
}

@end
