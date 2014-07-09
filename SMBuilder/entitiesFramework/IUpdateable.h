//
//  IUpdateable.h
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameTime;
@class Signal1;

@protocol IUpdateable <NSObject>

@property(nonatomic, assign) BOOL Active;
@property(nonatomic, assign) int UpdateOrder;

- (void) Update:(GameTime*)time;

@property(nonatomic, readonly) Signal1* UpdateOrderChanged;
@property(nonatomic, readonly) Signal1* ActiveChanged;

@end
