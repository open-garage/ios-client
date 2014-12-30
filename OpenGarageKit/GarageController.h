//
//  GarageController.h
//  GarageOpen
//
//  Created by Patrick Steiner on 09.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageKey.h"

typedef NS_ENUM(NSInteger, GarageDoorStatus) {
    GarageDoorStatusError = -1,
    GarageDoorStatusClosed = 0,
    GarageDoorStatusOpen = 1
};

@class GarageController;

@protocol GarageControllerDelegate

- (void)openGarageServerReachabilityChanged:(BOOL)reachable;

@end

@interface GarageController : NSObject

@property (weak, nonatomic) id <GarageControllerDelegate> delegate;
@property (nonatomic) GarageKey *garageKey;
@property BOOL serverIsReachable;
@property BOOL debuggingMode;
@property GarageDoorStatus garageDoorStatus;

- (void)saveGarageKey:(GarageKey *)garageKey;
- (BOOL)garageKeyIsValid;

- (void)toggleWithResultBlock:(void (^)(BOOL success))resultBlock;
- (void)statusWithResultBlock:(void (^)(BOOL success, GarageDoorStatus status))resultBlock;

- (void)startMonitoringServer;
- (void)stopMonitoringServer;

@end
