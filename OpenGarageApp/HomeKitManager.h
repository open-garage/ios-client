//
//  HomeKitManager.h
//  OpenGarage
//
//  Created by Patrick Steiner on 04.04.15.
//  Copyright (c) 2015 Patrick Steiner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeKitManager : NSObject

- (void)homeKitBrowserAccessoryStart;
- (void)homeKitBrowserAccessoryStop;

@end
