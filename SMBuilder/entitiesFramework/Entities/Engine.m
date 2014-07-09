//
//  Engine.m
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "AbstractSystem.h"
#import "Engine.h"
#import "Entity.h"
#import "SetArray.h"

#import "Filter.h"

@implementation Engine
@synthesize updateOrder;

- (id) init {
    return [self initWithComponentsCount:10];
}

- (id) initWithComponentsCount:(int)componentsCount {
    if ((self = [super init])) {
        _componentIndexes = [[NSMutableDictionary alloc] init];
        _ComponentsCount = componentsCount;
        _allEntities = [[SetArray alloc] init];
        _entitiesMap = [[NSMutableDictionary alloc] init];
        
        _SystemCollection = [[NSMutableArray alloc] init];
    }
    return self;
}


- (Index*) GetComponentIndex:(FastString*)componentName {
    int index = 0;
    NSNumber* val_index = [_componentIndexes objectForKey:componentName];
    if (val_index == nil) {
        [_componentIndexes setObject:[NSNumber numberWithInteger:_lastComponentIndex] forKey:componentName];
        index = _lastComponentIndex;
        ++ _lastComponentIndex;
    }
    else
        index = [val_index intValue];
    
    return [[Index alloc] initWithIndex:index andWithName:componentName];
}

- (NSObject<IArrayHolder>*) GetAllEntities {
    return _allEntities;
}

- (void) OnComponentAdded:(Entity*) entity {
    UInt64 mask = entity.Filter.Mask ^ entity.OldFilter.Mask;
    for (Filter* filter in _entitiesMap.allKeys) {
        if ((filter.Mask & entity.Filter.Mask) == filter.Mask) {
            if ((filter.Mask & mask) != 0) {
                SetArray* setArray = (SetArray*)[_entitiesMap objectForKey:filter];
                [setArray Add:entity];
            }
        }
    }
}

- (void) OnComponentRemoved:(Entity*) entity {
    UInt64 mask = entity.Filter.Mask ^ entity.OldFilter.Mask;
    for (Filter* filter in _entitiesMap.allKeys) {
        if ((filter.Mask & entity.OldFilter.Mask) == filter.Mask) {
            if ((filter.Mask & mask) != 0) {
                SetArray* setArray = (SetArray*)[_entitiesMap objectForKey:filter];
                [setArray Remove:entity];
            }
        }
    }
}

- (void) OnFilterChange:(Entity*) entity {
    if (entity.OldFilter.Mask < entity.Filter.Mask)
        [self OnComponentAdded:entity];
    else
        [self OnComponentRemoved:entity];
}


- (NSObject<IArrayHolder>*) GetEntities:(Filter*)filter {
    SetArray* collection = nil;
    
    collection = [_entitiesMap objectForKey:filter];
    if (collection == nil) {
        collection = [[SetArray alloc] init];
        [_entitiesMap setObject:collection forKey:filter];
        
        NSArray* allArray = _allEntities.Array;
        for (Entity* entity in allArray) {
            if ((entity.Filter.Mask & filter.Mask) == filter.Mask) {
                [collection Add:entity];
            }
        }
    }
    
    return collection;
}

- (void) RegisterEntity:(Entity*)entity {
    [_allEntities Add:entity];
    for (Filter* filter in _entitiesMap.allKeys) {
        if ((filter.Mask & entity.Filter.Mask) == filter.Mask) {
            SetArray* setArray = (SetArray*)[_entitiesMap objectForKey:filter];
            [setArray Add:entity];
        }
    }
    
    [entity.FilterChange addListener:self action:@selector(OnFilterChange:)];
}

- (void) UnregisterEntity:(Entity*)entity {
    [_allEntities Remove:entity];
    for (Filter* filter in _entitiesMap.allKeys) {
        if ((filter.Mask & entity.Filter.Mask) == filter.Mask) {
            SetArray* setArray = (SetArray*)[_entitiesMap objectForKey:filter];
            [setArray Remove:entity];
        }
    }
    
    [entity.FilterChange removeListener:self action:@selector(OnFilterChange:)];
}

-(void) removeAllSystems {
    [_SystemCollection removeAllObjects];
}

-(void) removeAllEntities {
    NSArray* arr = [NSMutableArray arrayWithArray:[_allEntities Array]];
    for (Entity* entity in arr) {
        [entity Unregister];
    }
    [_entitiesMap removeAllObjects];
}

- (Filter*) GetFilterByName:(NSArray*)names {
    Filter* filter = [[Filter alloc] initWithMask:0];
    for (int i = 0; i < [names count]; ++i) {
        Index* index = [self GetComponentIndex:[names objectAtIndex:i]];
        filter.Mask |= (UInt64)1 << index.ComponentIndex;
    }
    return filter;
}

- (Filter*) GetFilterByIndex:(NSArray*)indexes {
    Filter* filter = [[Filter alloc] initWithMask:0];
    for (int i = 0; i < [indexes count]; ++i) {
        filter.Mask |= (UInt64)1 << ((Index*)[indexes objectAtIndex:i]).ComponentIndex;
    }
    return filter;
}

- (AbstractSystem*) getSystemByKey:(NSString*)key
{
	for (AbstractSystem *system in self.SystemCollection)
	{
		if ([system.systemKey isEqualToString:key])
		{
			return system;
		}
	}
	return nil;
}

- (void)update:(ccTime)time {
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"updateOrder" ascending:YES];
    [_SystemCollection sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
    for (int i = 0; i < _SystemCollection.count; ++i)
	{
		AbstractSystem *system = (AbstractSystem *)[_SystemCollection objectAtIndex:i];
		if (system.Active)
			[system update:time];
	}
}

@end
