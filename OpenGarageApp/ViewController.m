//
//  ViewController.m
//  OpenGarageApp
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <OpenGarageKit/OpenGarageKit.h>
#import "ViewController.h"
#import "SettingsViewController.h"

@interface ViewController () <SettingsViewControllerDelegate, GarageControllerDelegate, BeaconControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIView *garageDoorView;

@property (nonatomic) GarageController *garageController;
@property (nonatomic) BeaconController *beaconController;

@property BOOL closeDoor;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (DEBUGGING_MODE == YES) {
        [_toggleButton setTitle:@"Toggle (Debug)" forState:UIControlStateNormal];
    }
    
    if ([self loadBeaconStatus]) {
        [self.beaconController startMonitoringForBeacons];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.garageController startMonitoringServer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.garageController stopMonitoringServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (GarageController *)garageController
{
    if (_garageController == nil) {
        _garageController = [[GarageController alloc] init];
        _garageController.delegate = self;
        
        // enable / disable debugging mode
        _garageController.debuggingMode = DEBUGGING_MODE;
    }
    
    return _garageController;
}

- (BeaconController *)beaconController
{
    if (_beaconController != nil) {
        return _beaconController;
    }
    
    _beaconController = [[BeaconController alloc] init];
    _beaconController.delegate = self;
    
    return _beaconController;
}

- (BOOL)loadBeaconStatus
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.at.helmsdeep.opengarage"];
    
    return [defaults boolForKey:kBeacon];
}

- (IBAction)toggleButtonPushed:(id)sender
{
    if ([self.garageController garageKeyIsValid]) {
        _toggleButton.enabled = NO;
        
        [self addSystemSpringAnimationToView:_garageDoorView andOpenDoor:_closeDoor];
        
        [self.garageController toggleWithResultBlock:^(BOOL success) {
            if (success) {
                //alert.message = NSLocalizedString(@"Successfully toggled garage door", @"Garage door successfully opened dialog");
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Garage Door", @"Garage Door Open Dialog")
                                                                               message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [alert addAction:okButton];
                
                alert.message = NSLocalizedString(@"Error while toggling garage door", @"Error while toggling garage door dialog");
                [self presentViewController:alert animated:YES completion:nil];
            }
            //_toggleButton.enabled = YES;
        }];
    } else {
        [self performSegueWithIdentifier:@"showSettings" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        SettingsViewController *settingsViewController = navigationController.viewControllers[0];
        settingsViewController.delegate = self;
        settingsViewController.garageKey = self.garageController.garageKey;
        settingsViewController.iBeaconState = [self.beaconController isMonitoring];
    }
}

#pragma mark - SettingsViewController delegate methods

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller withGarageKey:(GarageKey *)garageKey
{
    [self.garageController saveGarageKey:garageKey];
}

- (void)settingsViewController:(SettingsViewController *)controller changedBeaconStatusTo:(BOOL)status
{
    if (!status && [self.beaconController isMonitoring]) {
        [self.beaconController stopMonitoringForBeacons];
    } else if (status && ![self.beaconController isMonitoring]) {
        [self.beaconController startMonitoringForBeacons];
    }
}

#pragma mark - GarageController delegate methods

- (void)openGarageServerReachabilityChanged:(BOOL)reachable
{
    if (reachable) {
        _toggleButton.enabled = YES;
    } else {
        _toggleButton.enabled = NO;
    }
}

#pragma mark - BeaconController delegate methods

- (void)beaconController:(BeaconController *)controller foundBeaconWithUUID:(NSUUID *)uuid withMajor:(NSNumber *)major andWithMinor:(NSNumber *)minor
{
    NSLog(@"INFO: Found Open-Garage iBeacon");
}

#pragma mark - Animation methods

- (void) addSystemSpringAnimationToView:(UIView *)view andOpenDoor:(BOOL)open
{
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGFloat amount = 60;
                         
                         if (open) {
                             if (view.frame.origin.x == 50) {
                                 view.frame = CGRectOffset(view.frame, 0, amount);
                             } else {
                                 view.frame = CGRectOffset(view.frame, 0, -amount);
                             }
                         } else {
                             if (view.frame.origin.x == 50) {
                                 view.frame = CGRectOffset(view.frame, 0, -amount);
                             } else {
                                 view.frame = CGRectOffset(view.frame, 0, amount);
                             }
                         }
                         
                     } completion:^(BOOL finished) {
                         if (_closeDoor) {
                             _closeDoor = NO;
                         } else {
                             _closeDoor = YES;
                         }
                         
                         _toggleButton.enabled = YES;
                     }];
}

@end
