//
//  MeterViewController.m
//  Date Bomb
//
//  Created by Paul Collier on 12-03-10.
//  Copyright (c) 2012 Archipelago. All rights reserved.
//

#import "MeterViewController.h"
#import "DatingService.h"

@interface MeterViewController ()
{
    DatingService *service;
    NSTimer *pollTimer;
    BOOL wasShowingHeart;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *myRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *theirRatingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;

@end

@implementation MeterViewController
@synthesize titleLabel;
@synthesize myRatingLabel;
@synthesize theirRatingLabel;
@synthesize heartImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    service = [DatingService sharedInstance];
    [service addObserver:self forKeyPath:@"otherName"];
    [service addObserver:self forKeyPath:@"myRating"];
    [service addObserver:self forKeyPath:@"theirRating"];
    service.myRating = 50;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    pollTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(poll) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [pollTimer invalidate];
    pollTimer = nil;
}

- (void)viewDidUnload
{
    
    [service removeObserver:self forKeyPath:@"otherName"];
    [service removeObserver:self forKeyPath:@"myRating"];
    [service removeObserver:self forKeyPath:@"theirRating"];
    service = nil;

    [self setTitleLabel:nil];
    [self setMyRatingLabel:nil];
    [self setTheirRatingLabel:nil];
    [self setHeartImageView:nil];
    [super viewDidUnload];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"otherName"])
    {
        self.titleLabel.text = [NSString stringWithFormat:@"Date with %@", service.otherName];
    }
    else if ([keyPath isEqualToString:@"myRating"])
    {
        self.myRatingLabel.text = [NSString stringWithFormat:@"%d", service.myRating];
        if (service.myRating <= 0)
        {
            [self performSegueWithIdentifier:@"bombed" sender:self];
        }
    }
    else if ([keyPath isEqualToString:@"theirRating"])
    {
        self.theirRatingLabel.text = [NSString stringWithFormat:@"%d", service.theirRating];
        if (service.theirRating <= 0)
        {
            [self performSegueWithIdentifier:@"bombed" sender:self];
        }
        else
        {
            BOOL showHeart = service.theirRating >= 100;
            if (showHeart != wasShowingHeart)
            {
                wasShowingHeart = showHeart;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                heartImageView.alpha = showHeart ? 1.0 : 0.0;
                [UIView commitAnimations];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)voteUp:(id)sender
{
    NSInteger rating = service.myRating;
    service.myRating = MIN(rating + 5, 100);
}

- (IBAction)voteDown:(id)sender
{
    NSInteger rating = service.myRating;
    service.myRating = MAX(rating - 5, 0);
}

- (void)poll
{
    [service poll];
}

@end
