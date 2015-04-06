//
//  ViewController.m
//  OpenGarageApp
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "ViewController.h"
#import "SettingsViewController.h"
#import "GarageDoorView.h"

@interface ViewController () <SettingsViewControllerDelegate, GarageControllerDelegate, BeaconControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet GarageDoorView *garageDoorView;

@property (nonatomic) GarageController *garageController;
@property (nonatomic) BeaconController *beaconController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (DEBUGGING_MODE == YES) {
        [_refreshButton setTitle:@"Refresh (Debug)" forState:UIControlStateNormal];
    }
    
    if ([self loadBeaconStatus]) {
        [self.beaconController startMonitoringForBeacons];
    }
    
    // add gesture recognizer the the garage door view
    UITapGestureRecognizer *tapGarageDoor = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(garageDoorViewPushed:)];
    [_garageDoorView setUserInteractionEnabled:YES];
    [_garageDoorView addGestureRecognizer:tapGarageDoor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.garageController startMonitoringServer];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.garageController statusWithResultBlock:^(BOOL success, GarageDoorStatus status) {
        if (success) {
            [self setupUIWithGarageDoorStatus:status];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
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

- (void)setupUIWithGarageDoorStatus:(GarageDoorStatus)doorStatus
{
    switch (doorStatus) {
        case GarageDoorStatusClosed:
            [_garageDoorView closeDoor];
            break;
        case GarageDoorStatusOpen:
            [_garageDoorView openDoor];
            break;
        default:
            [_garageDoorView setStatusLabelText:@"ERROR"];
            break;
    }
}

- (BOOL)loadBeaconStatus
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.at.helmsdeep.opengarage"];
    
    return [defaults boolForKey:kBeacon];
}

- (IBAction)refreshButtonPushed:(id)sender
{
    if ([self.garageController garageKeyIsValid]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        [self.garageController statusWithResultBlock:^(BOOL success, GarageDoorStatus status) {
            if (success) {
                [self setupUIWithGarageDoorStatus:status];
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    } else {
        [self performSegueWithIdentifier:@"showSettings" sender:self];
    }
}

- (void)garageDoorViewPushed:(id)sender
{
    if ([self.garageController garageKeyIsValid]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        [self.garageController toggleWithResultBlock:^(BOOL success) {
            if (success) {
                [_garageDoorView toggleDoor];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Garage Door", @"Garage Door Open Dialog")
                                                                               message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [alert addAction:okButton];
                
                alert.message = NSLocalizedString(@"Error while toggling garage door", @"Error while toggling garage door dialog");
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
        _refreshButton.enabled = YES;
        _garageDoorView.userInteractionEnabled = YES;
    } else {
        _refreshButton.enabled = NO;
        _garageDoorView.userInteractionEnabled = NO;
    }
}

#pragma mark - BeaconController delegate methods

- (void)beaconController:(BeaconController *)controller foundBeaconWithUUID:(NSUUID *)uuid withMajor:(NSNumber *)major andWithMinor:(NSNumber *)minor
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.garageController statusWithResultBlock:^(BOOL success, GarageDoorStatus status) {
        if (success) {
            [self setupUIWithGarageDoorStatus:status];
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

@end
