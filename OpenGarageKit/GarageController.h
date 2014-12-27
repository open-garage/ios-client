//
//  GarageController.h
//  GarageOpen
//
//  Created by Patrick Steiner on 09.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageKey.h"

@class GarageController;

@protocol GarageControllerDelegate

- (void)openGarageServerReachabilityChanged:(BOOL)reachable;

@end

@interface GarageController : NSObject

@property (nonatomic) GarageKey *garageKey;
@property BOOL serverIsReachable;
@property (weak, nonatomic) id <GarageControllerDelegate> delegate;
@property BOOL debuggingMode;

- (void)saveGarageKey:(GarageKey *)garageKey;
- (BOOL)garageKeyIsValid;

- (void)toggleWithResultBlock:(void (^)(BOOL success))resultBlock;
- (void)statusWithResultBlock:(void (^)(BOOL success))resultBlock;

- (void)startMonitoringServer;
- (void)stopMonitoringServer;

@end
