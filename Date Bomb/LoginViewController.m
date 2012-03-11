//
//  ViewController.m
//  Date Bomb
//
//  Created by Paul Collier on 12-03-10.
//  Copyright (c) 2012 Archipelago. All rights reserved.
//

#import "LoginViewController.h"
#import "DatingService.h"

@interface LoginViewController ()
{
    DatingService *service;
}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingMessage;

@end

@implementation LoginViewController
@synthesize name;
@synthesize loadingIndicator;
@synthesize loadingMessage;

- (void)viewDidLoad
{
    service = [DatingService sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[name becomeFirstResponder];
    [service addObserver:self forKeyPath:@"isLoading"];
    [service addObserver:self forKeyPath:@"otherName"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [service removeObserver:self forKeyPath:@"isLoading"];
    [service removeObserver:self forKeyPath:@"otherName"];
}

- (void)viewDidUnload
{
    [self setName:nil];
    [self setLoadingIndicator:nil];
    [self setLoadingMessage:nil];
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [name resignFirstResponder];
    [service loginWithName:name.text];
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isLoading"])
    {
        if (service.isLoading)
        {
            [loadingIndicator startAnimating];
            loadingMessage.hidden = NO;
        }
        else
        {
            [loadingIndicator stopAnimating];
            loadingMessage.hidden = YES;
        }
    }
    else if ([keyPath isEqualToString:@"otherName"])
    {
        if (service.otherName)
        {
            [self performSegueWithIdentifier:@"loggedIn" sender:self];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
