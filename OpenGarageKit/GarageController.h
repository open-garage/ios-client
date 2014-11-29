//
//  GarageController.h
//  GarageOpen
//
//  Created by Patrick Steiner on 09.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GarageController : NSObject

- (void)toggleWithResultBlock:(void (^)(BOOL success))resultBlock;

@end
