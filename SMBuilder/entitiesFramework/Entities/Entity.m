//
//  Entity.m
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "Entity.h"
#import "Engine.h"
#import "Index.h"

@implementation Entity

- (id) initWithEngine:(Engine*)engine {
    if ((self = [super init])) {
        _components = [[NSMutableArray alloc] initWithCapacity:engine.ComponentsCount];
        for (int i = 0; i < engine.ComponentsCount; i++)
            [_components addObject:[NSNull null]];
        self.engine = engine;
        
        _Filter = [[Filter alloc] initWithMask:0];
        _OldFilter = [[Filter alloc] initWithMask:0];
    }
    
    return self;
}

- (void) setFilter:(Filter *)Filter {
    if (![_Filter isEqual:Filter]) {
        _OldFilter.Mask = _Filter.Mask;
        _Filter.Mask = Filter.Mask;
        
        [self.Engine OnFilterChange:self];
    }
}

- (NSObject<IDataHolder>*) objectAtIndex:(int)index {
    return (NSObject<IDataHolder>*)[_components objectAtIndex:index];
}

- (void) Register {
    [self.Engine RegisterEntity:self];
}

- (void) Unregister {
    [self.Engine UnregisterEntity:self];
}

- (NSObject*) Get:(Index*)index {
    NSObject<IDataHolder>* obj = (NSObject<IDataHolder>*)[_components objectAtIndex:index.ComponentIndex];
    
    if ([obj isKindOfClass:[ComponentsDataHolder class]]) {
        return ((ComponentsDataHolder*)obj).Data;
    }
    else {
        return nil;
    }
}

- (void) Set:(Index*)index withObject:(NSObject*)object {
    NSObject<IDataHolder>* obj = (NSObject<IDataHolder>*)[_components objectAtIndex:index.ComponentIndex];
    
    if ([obj isKindOfClass:[ComponentsDataHolder class]]) {
        ((ComponentsDataHolder*)obj).Data = object;
    }
}

- (Index*) AddComponent:(FastString*)componentName withComponent:(NSObject*)component {
    _OldFilter.Mask = _Filter.Mask;
    Index* index = [self.Engine GetComponentIndex:componentName];
    int idx = index.ComponentIndex;
    _Filter.Mask |= (UInt64)1 << idx;
    [_components replaceObjectAtIndex:idx withObject:[[ComponentsDataHolder alloc] initWithData:component]];
    [self.Engine OnFilterChange:self];
    return index;
}

- (void) RemoveComponent:(FastString*)componentName {
    _OldFilter.Mask = _Filter.Mask;
    Index *index = [self.Engine GetComponentIndex:componentName];
    int idx = index.ComponentIndex;
    _Filter.Mask &= ~((UInt64)1 << idx);
    [_components replaceObjectAtIndex:idx withObject:[NSNull null]];
    [self.Engine OnFilterChange:self];
}

-(id) copyWithZone: (NSZone*) zone
{
	Entity *copy = [[[self class] allocWithZone:zone] initWithEngine:_Engine];
	copy->_OldFilter = _OldFilter.copy;
	copy->_Filter = _Filter.copy;
	copy->_components = _components.copy;
	return copy;
}


@end
