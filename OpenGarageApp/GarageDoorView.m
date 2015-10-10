//
//  GarageDoorView.m
//  OpenGarage
//
//  Created by Patrick Steiner on 30.12.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <OpenGarageKit/OpenGarageKit.h>
#import "GarageDoorView.h"

@interface GarageDoorView ()

@property (nonatomic) UIView *garageDoor;
@property (nonatomic) UILabel *statusLabel;
@property GarageDoorStatus garageDoorStatus;

@end

@implementation GarageDoorView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    // remove background color
    self.backgroundColor = [UIColor clearColor];
    
    // set initial status to closed
    _garageDoorStatus = GarageDoorStatusClosed;
    
    // garage door
    _garageDoor = [[UIView alloc] initWithFrame:CGRectMake(10, 30, (self.bounds.size.width - 20), self.bounds.size.height - 30)];
    _garageDoor.backgroundColor = [UIColor redColor];
    _garageDoor.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    // center the anchor point horizontally
    _garageDoor.layer.anchorPoint = CGPointMake(0.5, 0.0);
    _garageDoor.layer.position = CGPointMake((self.bounds.size.width / 2), 30);
    
    [self addSubview:_garageDoor];
    
    // garage top wall
    UIView *garageWall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
    garageWall.backgroundColor = [UIColor blueColor];
    [self addSubview:garageWall];
    [self bringSubviewToFront:garageWall];
    
    // status label
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 25)];
    [self setDoorStatus:GarageDoorStatusUnknown];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.textColor = [UIColor whiteColor];
    [self addSubview:_statusLabel];
}

- (void)setStatusLabelText:(NSString *)statusText
{
    [_statusLabel setText:[NSString stringWithFormat:@"Status: %@", statusText]];
}

- (void)closeDoor
{
    [self setDoorStatus:GarageDoorStatusClosed];
}

- (void)openDoor
{
    [self setDoorStatus:GarageDoorStatusOpen];
}

- (void)toggleDoor
{
    if (_garageDoorStatus == GarageDoorStatusOpen) {
        [self setDoorStatus:GarageDoorStatusClosed];
    } else if (_garageDoorStatus == GarageDoorStatusClosed) {
        [self setDoorStatus:GarageDoorStatusOpen];
    }
}

- (void)setDoorStatus:(GarageDoorStatus)doorStatus
{
    _garageDoorStatus = doorStatus;
    
    switch (_garageDoorStatus) {
        case GarageDoorStatusOpen:
            [self setStatusLabelText:@"Open"];
            break;
        case GarageDoorStatusClosed:
            [self setStatusLabelText:@"Closed"];
            break;
        case GarageDoorStatusError:
            [self setStatusLabelText:@"Error"];
            break;
        default:
            [self setStatusLabelText:@"Unknown"];
            break;
    }
    
    [self addDoorAnimationToView:_garageDoor andGarageDoorStatus:_garageDoorStatus];
}

- (void)addDoorAnimationToView:(UIView *)view andGarageDoorStatus:(GarageDoorStatus)status
{
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (status == GarageDoorStatusOpen) {
                             _garageDoor.transform = CGAffineTransformMakeScale(1.0, 0.2);
                         } else {
                             _garageDoor.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
                     } completion:^(BOOL finished) {
                     }];
}

@end
