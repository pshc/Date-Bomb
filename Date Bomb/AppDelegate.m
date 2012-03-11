//
//  AppDelegate.m
//  Date Bomb
//
//  Created by Paul Collier on 12-03-10.
//  Copyright (c) 2012 Archipelago. All rights reserved.
//

#import "AppDelegate.h"
#import "DatingService.h"

@interface AppDelegate ()
{
    UIApplication *app;
    DatingService *service;
}
@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    app = application;
    service = [DatingService sharedInstance];
    [service addObserver:self forKeyPath:@"isLoading" options:0 context:nil];
    [service addObserver:self forKeyPath:@"error" options:0 context:nil];
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isLoading"])
    {
        app.networkActivityIndicatorVisible = service.isLoading;
    }
    else if ([keyPath isEqualToString:@"error"])
    {
        if (service.error)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:service.error delegate:nil cancelButtonTitle:@"Darn" otherButtonTitles:nil] show];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
