//
//  GameComponent.m
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "GameComponent.h"
#import "Signal1.h"

@implementation GameComponent

- (id) initWithGame:(Game*)game {
    if ((self = [super init])) {
        _Game = game;
        
        _InGame = NO;
        
        _IsInitialized = NO;
        
        _UpdateOrderChanged = [[Signal1 alloc] init];
        _ActiveChanged = [[Signal1 alloc] init];
        
        _Actions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc {
    [self Deinitialize];
}

- (void) Initialize {
    if (!_IsInitialized) {
        _IsInitialized = YES;
    }
}

- (void) Deinitialize {
    if (_IsInitialized) {
        _IsInitialized = NO;
    }
}

- (void) Update:(GameTime*)time {
}

- (void) setActive:(BOOL)Active {
    if (_Active != Active) {
        _Active = Active;
        [_ActiveChanged dispatchWithObject:self];
    }
}

- (void) setUpdateOrder:(int)UpdateOrder {
    if (_UpdateOrder != UpdateOrder) {
        _UpdateOrder = UpdateOrder;
        [_UpdateOrderChanged dispatchWithObject:self];
    }
}

@end
