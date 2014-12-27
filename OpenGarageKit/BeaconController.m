//
//  BeaconController.m
//  OpenGarage
//
//  Created by Patrick Steiner on 27.12.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "BeaconController.h"

@interface BeaconController ()

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) CLBeacon *currentBeacon;

@property BOOL isCurrentlyMonitoring;

@end

@implementation BeaconController

- (CLLocationManager *)locationManager
{
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    
    // Open-Garage iBeacon UUID
    NSString *openGarageBeaconID = @"649F1C4B-8EF1-4E5C-A99E-81470F515FF9";
    NSString *openGarageBeaconDescription = @"OpenGarage iBeacon";
    
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:openGarageBeaconID];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:openGarageBeaconDescription];
    
    // notify only if display is on
    _beaconRegion.notifyEntryStateOnDisplay = YES;
    _beaconRegion.notifyOnEntry = YES;
    _beaconRegion.notifyOnExit = YES;
    
    _locationManager.delegate = self;
    [_locationManager requestAlwaysAuthorization];
    
    return _locationManager;
}

- (void)startMonitoringForBeacons
{
    _isCurrentlyMonitoring = YES;
    [self.locationManager startMonitoringForRegion:_beaconRegion];
}

- (void)stopMonitoringForBeacons
{
    [self.locationManager stopRangingBeaconsInRegion:_beaconRegion];
    [self.locationManager stopMonitoringForRegion:_beaconRegion];
    _isCurrentlyMonitoring = NO;
}

- (BOOL)isMonitoring
{
    return _isCurrentlyMonitoring;
}

- (BOOL)isCurrentBeacon:(CLBeacon *)newBeacon
{
    if (_currentBeacon == nil) {
        return NO;
    }
    
    if ([_currentBeacon.proximityUUID.UUIDString isEqualToString:newBeacon.proximityUUID.UUIDString]) {
        if ([_currentBeacon.major doubleValue] == [newBeacon.major doubleValue]) {
            if ([_currentBeacon.minor doubleValue] == [newBeacon.minor doubleValue]) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - CoreLocation delegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            [self.locationManager startRangingBeaconsInRegion:_beaconRegion];
            break;
            
        default:
            [self.locationManager stopRangingBeaconsInRegion:_beaconRegion];
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"DBG: %s", __FUNCTION__);
    [self.locationManager startRangingBeaconsInRegion:_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"DBG: %s", __FUNCTION__);
    [self.locationManager stopRangingBeaconsInRegion:_beaconRegion];
    
    // reset current beacon
    _currentBeacon = nil;
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] > 0) {
        CLBeacon *nearestBeacon = [beacons firstObject];
        
        if (![self isCurrentBeacon:nearestBeacon]) {
            _currentBeacon = nearestBeacon;
            
            [self.delegate beaconController:self
                        foundBeaconWithUUID:_currentBeacon.proximityUUID
                                  withMajor:_currentBeacon.major
                               andWithMinor:_currentBeacon.minor];
        }
    }
}

@end
