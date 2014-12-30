//
//  GarageDoorView.h
//  OpenGarage
//
//  Created by Patrick Steiner on 30.12.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GarageDoorView : UIView

- (void)setStatusLabelText:(NSString *)statusText;

- (void)openDoor;
- (void)closeDoor;
- (void)toggleDoor;

@end
