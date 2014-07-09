//
//  GameComponentCollection.m
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "GameComponentCollection.h"

#import "IUpdateable.h"
#import "IDrawable.h"

#import "Signal1.h"
#import "Signal2.h"

@implementation GameComponentCollection

- (id) init {
    if ((self = [super init])) {
        _all = [[NSMutableArray alloc] init];
        _updateableCollectionChanged = YES;
        _drawableCollectionChanged = YES;
        
        _ComponentAdded = [[Signal1 alloc] init];
        _ComponentRemoved = [[Signal2 alloc] init];
    }
    
    return self;
}


- (void) OnUpdateableStateChanged:(NSObject<IUpdateable>*)component {
    _updateableCollectionChanged = YES;
}

- (void) OnDrawableStateChanged:(NSObject<IDrawable>*)component {
    _drawableCollectionChanged = YES;
}

- (void) Add:(NSObject*)component {
    [_all addObject:component];
    
    if ([component conformsToProtocol:@protocol(IUpdateable)]) {
        NSObject<IUpdateable>* c = (NSObject<IUpdateable>*)component;
        [c.ActiveChanged addListener:self action:@selector(OnUpdateableStateChanged)];
        [c.UpdateOrderChanged addListener:self action:@selector(OnUpdateableStateChanged)];
        _updateableCollectionChanged = YES;
    }
    if ([component conformsToProtocol:@protocol(IDrawable)]) {
        NSObject<IDrawable>* c = (NSObject<IDrawable>*)component;
        [c.DrawOrderChanged addListener:self action:@selector(OnDrawableStateChanged)];
        [c.VisibleChanged addListener:self action:@selector(OnDrawableStateChanged)];
        _drawableCollectionChanged = YES;
    }
    [_ComponentAdded dispatchWithObject:component];
}

- (void) Remove:(NSObject*)component {
    [self Remove:component shouldDeinitialize:YES];
}

- (void) Remove:(NSObject*)component shouldDeinitialize:(BOOL)deinitialize {
    if ([component conformsToProtocol:@protocol(IUpdateable)]) {
        NSObject<IUpdateable>* c = (NSObject<IUpdateable>*)component;
        [c.ActiveChanged removeListener:self action:@selector(OnUpdateableStateChanged)];
        [c.UpdateOrderChanged removeListener:self action:@selector(OnUpdateableStateChanged)];
        _updateableCollectionChanged = YES;
    }
    
    if ([component conformsToProtocol:@protocol(IDrawable)]) {
        NSObject<IDrawable>* c = (NSObject<IDrawable>*)component;
        [c.DrawOrderChanged removeListener:self action:@selector(OnDrawableStateChanged)];
        [c.VisibleChanged removeListener:self action:@selector(OnDrawableStateChanged)];
        _drawableCollectionChanged = YES;
    }
    
    [_all removeObject:component];
    [_ComponentRemoved dispatchWithObject:component withObject:[NSNumber numberWithBool:deinitialize]];
}

- (void) RemoveAll:(BOOL)deinitialize {
    _updateableCollectionChanged = YES;
    _drawableCollectionChanged = YES;
    
    for (NSObject* component in _all) {
        [_ComponentRemoved dispatchWithObject:component withObject:[NSNumber numberWithBool:deinitialize]];
    }
    
    [_all removeAllObjects];
}

- (NSArray*) All {
    return _all;
}

NSInteger sortIUpdateable(id a, id b, void* userData) {
    NSObject<IUpdateable>* A = (NSObject<IUpdateable>*)a;
    NSObject<IUpdateable>* B = (NSObject<IUpdateable>*)b;
    
    int res = A.UpdateOrder - B.UpdateOrder;
    if (res <= -1) {
        return -1;
    }
    else if (res >= 1) {
        return 1;
    }
    else {
        return 0;
    }
}

- (NSArray*) Updateable {
    if (_updateableCollectionChanged) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        for (NSObject* component in _all) {
            if ([component conformsToProtocol:@protocol(IUpdateable)]) {
                NSObject<IUpdateable>* c = (NSObject<IUpdateable>*)component;
                if (c.Active) {
                    [array addObject:c];
                }
            }
        }
        
        _updateableCollectionChanged = NO;
        
        [array sortUsingFunction:sortIUpdateable context:nil];
        
        _sortedUpdateable = array;
    }
    
    return _sortedUpdateable;
}

NSInteger sortIDrawable(id a, id b, void* userData) {
    NSObject<IDrawable>* A = (NSObject<IDrawable>*)a;
    NSObject<IDrawable>* B = (NSObject<IDrawable>*)b;
    
    int res = A.DrawOrder - B.DrawOrder;
    if (res <= -1) {
        return -1;
    }
    else if (res >= 1) {
        return 1;
    }
    else {
        return 0;
    }
}


- (NSArray*) Drawable {
    if (_drawableCollectionChanged) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        for (NSObject* component in _all) {
            if ([component conformsToProtocol:@protocol(IDrawable)]) {
                NSObject<IDrawable>* c = (NSObject<IDrawable>*)component;
                if (c.Visible) {
                    [array addObject:c];
                }
            }
        }
        
        _drawableCollectionChanged = NO;
        
        [array sortUsingFunction:sortIDrawable context:nil];
        
        _sortedDrawable = array;
    }
    
    return _sortedDrawable;
}

@end
