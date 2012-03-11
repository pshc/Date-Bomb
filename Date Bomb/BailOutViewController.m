//
//  BailOutViewController.m
//  Date Bomb
//
//  Created by Paul Collier on 12-03-10.
//  Copyright (c) 2012 Archipelago. All rights reserved.
//

#import "BailOutViewController.h"
#import <MessageUI/MessageUI.h>

@interface BailOutViewController ()
@property (weak, nonatomic) IBOutlet UIButton *bailOutButton;

@end

@implementation BailOutViewController

@synthesize bailOutButton;

- (void)viewDidUnload
{
    [self setBailOutButton:nil];
    [super viewDidUnload];
}

- (IBAction)bailOut
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *compose = [[MFMessageComposeViewController alloc] init];
        compose.recipients = [NSArray arrayWithObject:@"1-800-BAIL-OUT"];
        compose.body = @"Help! I'm at 123 Fake Street!";
        [self presentModalViewController:compose animated:YES];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Can't send text messages." message:@"You're on your own!" delegate:nil cancelButtonTitle:@"Oh no" otherButtonTitles:nil] show];
    }
}

@end
