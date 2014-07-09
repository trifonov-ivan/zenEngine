//
//  SetArray.m
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "SetArray.h"

@implementation SetArray

- (id) init {
    if ((self = [super init])) {
        _dirty = NO;
        _entities = [[NSArray alloc] init];
        _hash = [[NSMutableSet alloc] init];
    }
    
    return self;
}



- (NSArray*) Array {
    if (_dirty) {
        if (_entities)
        _entities = [_hash allObjects];
        _dirty = false;
    }
    return _entities;
}

- (BOOL) Add:(NSObject*)entity {
    BOOL res = ![_hash containsObject:entity];
    [_hash addObject:entity];
    _dirty |= res;
    return res;
}

- (BOOL) Remove:(NSObject*)entity {
    BOOL res = [_hash containsObject:entity];
    [_hash removeObject:entity];
    _dirty |= res;
    return res;
}

- (void) Clear {
    [_hash removeAllObjects];
    _dirty = YES;
}

@end
