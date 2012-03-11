//
//  DatingService.m
//  Date Bomb
//
//  Created by Paul Collier on 12-03-10.
//  Copyright (c) 2012 Archipelago. All rights reserved.
//

#import "DatingService.h"

@interface DatingService ()
{
    NSURL *serverURL;
    NSInteger pendingRequests;
    NSNumber *userId;
    NSInteger myRating;
}

@end

@implementation NSString (URLEncoding)
-(NSString *)urlEncode {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (__bridge CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}
@end

@implementation DatingService

@synthesize isLoading;
@synthesize error;
@synthesize otherName;
@synthesize theirRating;

+ (DatingService *)sharedInstance
{
    static DatingService *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[DatingService alloc] init];
    });
    return inst;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        serverURL = [NSURL URLWithString:@"http://10.0.0.126/Hack/Date/Module/"];
        myRating = 50;
        self.theirRating = 50;
    }
    return self;
}

- (void)gotResponse:(NSDictionary *)json
{
    if (!userId)
    {
        self.otherName = [json objectForKey:@"other"];
        userId = [json objectForKey:@"id"];
    }
    else if ([json objectForKey:@"result"])
    {
        if (![[json objectForKey:@"result"] boolValue])
        {
            self.error = @"Operation failed.";
        }
    }
    else if ([json objectForKey:@"me"] && [json objectForKey:@"other"])
    {
        //self.myRating = [[[json objectForKey:@"me"] objectForKey:@"score"] integerValue];
        self.theirRating = [[[json objectForKey:@"other"] objectForKey:@"score"] integerValue];
    }
    else
    {
        self.error = [NSString stringWithFormat:@"Unknown message: %@", json];
    }
}

- (void)call:(NSString *)name params:(NSDictionary *)params
{
    if (!pendingRequests)
    {
        self.isLoading = true;
    }
    pendingRequests++;

    // Assemble querystring
    NSMutableArray *query = [NSMutableArray array];
    for (NSString *param in params)
    {
        [query addObject:[NSString stringWithFormat:@"%@=%@", [param urlEncode], [[[params objectForKey:param] description] urlEncode]]];
    }
    if (userId)
    {
        [query addObject:[NSString stringWithFormat:@"id=%@", [[userId description] urlEncode]]];
    }
    NSString *queryString = [NSString stringWithFormat:@"%@?%@", name, [query componentsJoinedByString:@"&"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryString relativeToURL:serverURL]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err)
    {
        pendingRequests--;
        if (!pendingRequests)
        {
            self.isLoading = false;
        }
        
        if (err)
        {
            self.error = [err localizedFailureReason];
            return;
        }
        int statusCode = ((NSHTTPURLResponse *)resp).statusCode;
        if (statusCode != 200)
        {
            self.error = [NSString stringWithFormat:@"Got response code %d.", statusCode];
        }
        else
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if (err)
            {
                self.error = @"Corrupt response.";
            }
            else if ([json objectForKey:@"error"])
            {
                self.error = [json objectForKey:@"error"];
            }
            else
            {
                [self gotResponse:json];
            }
        }
    }];
    
}

#pragma mark - API calls

- (void)loginWithName:(NSString *)name
{
    [self call:@"getDates.php" params:[NSDictionary dictionaryWithObject:name forKey:@"me"]];
}

- (void)poll
{
    [self call:@"getScore.php" params:nil];
}

- (NSInteger)myRating
{
    return myRating;
}

- (void)setMyRating:(NSInteger)rating
{
    if (rating != myRating)
    {
        myRating = rating;
        NSNumber *score = [NSNumber numberWithInteger:rating];
        [self call:@"setScore.php" params:[NSDictionary dictionaryWithObject:score forKey:@"score"]];
    }
}

@end

@implementation NSObject (Observation)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionInitial context:nil];
}

@end