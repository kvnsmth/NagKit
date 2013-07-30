//
//  NagService.m
//  NagKit
//
//  Created by Caleb Davenport on 5/14/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

#import "NAGController.h"

#import <TargetConditionals.h>

static NSString * const NAGControllerHasShownAlertKey = @"NAGControllerHasShownAlert";
NSString * const NAGControllerApplicationLaunchEventName = @"NAGControllerApplicationLaunch";

@interface NAGController () <UIAlertViewDelegate>

@end

@implementation NAGController {
    NSMutableDictionary *_limits;
}

+ (void)load {
	@autoreleasepool {
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center
		 addObserver:self
		 selector:@selector(handleApplicationLaunchEvent:)
		 name:UIApplicationWillEnterForegroundNotification
		 object:nil];
        [center
		 addObserver:self
		 selector:@selector(handleApplicationLaunchEvent:)
		 name:UIApplicationDidFinishLaunchingNotification
		 object:nil];
	}
}


#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        _limits = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - Public

+ (instancetype)sharedController {
    static dispatch_once_t token;
    static id controller;
    dispatch_once(&token, ^{
        controller = [[self alloc] init];
    });
    return controller;
}


- (void)pushEvent:(NSString *)name {
    [self incrementCountForEvent:name];
    [self showAlertIfNeeded];
}


- (void)setThreshold:(NSUInteger)threshold forEvent:(NSString *)name {
    _limits[name] = @(threshold);
}


- (void)showAlertIfNeeded {
#if TARGET_IPHONE_SIMULATOR && 0
#else
    
    // Break and log if there is no app id
    if (![self.appID length]) {
        NSLog(@"[NagKit] No app identifier is set.");
        return;
    }
    
    // Break if the alert has already been shown
    if ([self hasShownAlert]) {
        return;
    }
    
    // Break if we are not above the threshold
    __block BOOL kick = NO;
    [_limits enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *object, BOOL *stop) {
        if ([self countForEvent:key] <= [object integerValue]) {
            *stop = kick = YES;
        }
    }];
    if (kick) {
        return;
    }
    
    // Break if the delegate says to
    id<NAGControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controllerShouldShowAlert:)]) {
        kick = [delegate controllerShouldShowAlert:self];
    }
    if (kick) {
        return;
    }
    
    // Show alert
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NAGControllerHasShownAlertKey];
    UIAlertView *alert = [[UIAlertView alloc] init];
    [self.delegate controller:self willShowAlert:alert];
    [alert show];
    
    
#endif
}


#pragma mark - Private

- (NSInteger)countForEvent:(NSString *)name {
    NSString *key = [@"NagKit" stringByAppendingString:name];
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}


- (void)incrementCountForEvent:(NSString *)name {
    BOOL increment = YES;
    id<NAGControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:shouldIncrementCountForEvent:)]) {
        increment = [delegate controller:self shouldIncrementCountForEvent:name];
    }
    if (increment) {
        NSInteger count = [self countForEvent:name] + 1;
        NSString *key = [@"NagKit" stringByAppendingString:name];
        [[NSUserDefaults standardUserDefaults] setInteger:count forKey:key];
    }
}


- (BOOL)hasShownAlert {
	return [[NSUserDefaults standardUserDefaults] boolForKey:NAGControllerHasShownAlertKey];
}


- (NSInteger)thresholdForEvent {
    return 0;
}


- (NSURL *)reviewURL {
	NSString *string = [NSString stringWithFormat:
						@"itms-apps://ax.itunes.apple.com/"
						"WebObjects/MZStore.woa/wa/viewContentsUserReviews?"
						"type=Purple+Software&id=%@",
						self.appID];
	return [NSURL URLWithString:string];
}


- (void)handleApplicationLaunchEvent:(NSNotification *)notification {
    UIApplication *app = [notification object];
    if (app.applicationState == UIApplicationStateInactive) {
        [self pushEvent:NAGControllerApplicationLaunchEventName];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSURL *URL = [self reviewURL];
        [[UIApplication sharedApplication] openURL:URL];
    }
}


@end
