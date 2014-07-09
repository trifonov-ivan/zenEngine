//
//  AbstractSystem.h
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IUpdatable.h"

@class Engine;
@class Signal1;

@interface AbstractSystem : NSObject<IUpdatable> {
    BOOL _active;
}

@property(nonatomic, assign) Engine* Engine;

- (id) initWithEngine:(Engine*)engine;

- (void) Register;
- (void) Unregister;

@property(nonatomic, assign) BOOL Active;

@property(nonatomic, readonly, strong) Signal1* ActiveChanged;

- (NSString*) systemKey;
+ (NSString*) systemKey;

@end
