//
//  SettingsViewController.m
//  OpenGarage
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tokenTextField.text = _token;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)saveButtonPushed:(id)sender {
    NSString *newToken = _tokenTextField.text;
    
    [_delegate settingsViewControllerDidFinish:self withToken:newToken];
}

@end
