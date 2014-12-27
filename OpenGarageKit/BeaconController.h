//
//  BeaconController.h
//  OpenGarage
//
//  Created by Patrick Steiner on 27.12.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@class BeaconController;

@protocol BeaconControllerDelegate

- (void)beaconController:(BeaconController *)controller foundBeaconWithUUID:(NSUUID *)uuid withMajor:(NSNumber *)major andWithMinor:(NSNumber *)minor;

@end

@interface BeaconController : NSObject <CLLocationManagerDelegate>

@property (weak, nonatomic) id<BeaconControllerDelegate> delegate;

- (void)startMonitoringForBeacons;
- (void)stopMonitoringForBeacons;
- (BOOL)isMonitoring;

@end
