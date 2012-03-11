//
//  IntroViewController.m
//  Date Bomb
//
//  Created by Paul Collier on 12-03-10.
//  Copyright (c) 2012 Archipelago. All rights reserved.
//

#import "IntroViewController.h"

@implementation IntroViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(startUp) userInfo:nil repeats:NO];
}

- (void)startUp
{
    [self performSegueWithIdentifier:@"startUp" sender:self];
}

@end
