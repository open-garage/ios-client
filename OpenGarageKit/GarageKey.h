//
//  GarageKey.h
//  OpenGarage
//
//  Created by Patrick Steiner on 09.12.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GarageKey : NSObject

@property (nonatomic) NSString *serverToken;
@property (nonatomic) NSString *serverHostname;
@property (nonatomic) NSNumber *serverPort;

- (void)saveKey;
- (BOOL)isValid;
- (NSString *)serverURL;

@end
