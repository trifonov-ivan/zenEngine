//
//  Engine.h
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FastString.h"
#import "Index.h"
#import "IArrayHolder.h"
#import "IUpdatable.h"

@class Entity;
@class SetArray;
@class Filter;
@class AbstractSystem;

@interface Engine : NSObject <IUpdatable> {
    NSMutableDictionary* _entitiesMap;
    SetArray* _allEntities;
    
    int _lastComponentIndex;
}

- (id) init;
- (id) initWithComponentsCount:(int)componentsCount;

@property(nonatomic, readonly) int ComponentsCount;
@property(nonatomic, readonly) NSMutableArray* SystemCollection;
@property(nonatomic, readonly) NSMutableDictionary* componentIndexes;

- (Index*) GetComponentIndex:(FastString*)componentName;

- (Filter*) GetFilterByName	:(NSArray*)names;
- (Filter*) GetFilterByIndex:(NSArray*)indexes;
- (void) OnFilterChange:(Entity*) entity;

- (NSObject<IArrayHolder>*) GetAllEntities;
- (NSObject<IArrayHolder>*) GetEntities:(Filter*)filter;

- (void) RegisterEntity:(Entity*)entity;
- (void) UnregisterEntity:(Entity*)entity;
- (void) removeAllSystems;
- (AbstractSystem*) getSystemByKey:(NSString*)key;
- (void) removeAllEntities;

@end
