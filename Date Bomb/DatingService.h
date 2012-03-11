//
//  DatingService.h
//  Date Bomb
//
//  Created by Paul Collier on 12-03-10.
//  Copyright (c) 2012 Archipelago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatingService : NSObject

+ (DatingService *)sharedInstance;
- (void)loginWithName:(NSString *)name;
- (void)poll;

@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSString *otherName;

@property (nonatomic) NSInteger myRating;
@property (nonatomic) NSInteger theirRating;

@end

@interface NSObject (Observation)
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
@end