//
//  SettingsViewController.m
//  OpenGarage
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController()

@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.garageKey && [self.garageKey isValid]) {
        _addressTextField.text = self.garageKey.serverAddress;
        _portTextField.text = [NSString stringWithFormat:@"%@", self.garageKey.serverPort];
        _tokenTextField.text = self.garageKey.serverToken;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (GarageKey *)garageKey
{
    if (_garageKey) {
        return _garageKey;
    }
    
    _garageKey = [[GarageKey alloc] init];
    
    return _garageKey;
}

- (IBAction)saveButtonPushed:(id)sender
{
    self.garageKey.serverAddress = _addressTextField.text;
    self.garageKey.serverPort = [NSNumber numberWithInteger:[_portTextField.text integerValue]];
    self.garageKey.serverToken = _tokenTextField.text;
    
    if ([self.garageKey isValid]) {
        [_delegate settingsViewControllerDidFinish:self withGarageKey:self.garageKey];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelButtonPushed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
