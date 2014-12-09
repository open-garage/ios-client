//
//  GarageController.h
//  GarageOpen
//
//  Created by Patrick Steiner on 09.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageKey.h"

@interface GarageController : NSObject

@property (nonatomic) GarageKey *garageKey;

- (void)saveGarageKey:(GarageKey *)garageKey;

- (void)toggleWithResultBlock:(void (^)(BOOL success))resultBlock;
- (void)statusWithResultBlock:(void (^)(BOOL success))resultBlock;

@end
