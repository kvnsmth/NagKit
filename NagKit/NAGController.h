//
//  NagController.h
//  NagKit
//
//  Created by Caleb Davenport on 5/14/13.
//  Copyright (c) 2013 Caleb Davenport. All rights reserved.
//

@protocol NAGControllerDelegate;

extern NSString * const NAGControllerApplicationLaunchEventName;

@interface NAGController : NSObject

@property (nonatomic, assign) id<NAGControllerDelegate> delegate;
@property (nonatomic, copy) NSString *appID;

+ (instancetype)sharedController;

- (void)pushEvent:(NSString *)name;

- (void)setThreshold:(NSUInteger)threshold forEvent:(NSString *)name;

- (void)showAlertIfNeeded;

@end

@protocol NAGControllerDelegate <NSObject>

@required

- (void)controller:(NAGController *)controller willShowAlert:(UIAlertView *)alert;

@optional

- (BOOL)controller:(NAGController *)controller shouldIncrementCountForEvent:(NSString *)name;

- (BOOL)controllerShouldShowAlert:(NAGController *)controller;

@end
