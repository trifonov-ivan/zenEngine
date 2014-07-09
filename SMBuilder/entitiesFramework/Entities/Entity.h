//
//  Entity.h
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IDataHolder.h"
#import "Filter.h"
#import "Index.h"
#import "FastString.h"
#import "Signal1.h"

@class Engine;

@interface Entity : NSObject {
    NSMutableArray* _components;
}

@property(nonatomic, unsafe_unretained) Engine* Engine;
@property(nonatomic, readonly) Filter* OldFilter;
@property(nonatomic, strong) Filter* Filter;
@property(nonatomic, readonly) Signal1* FilterChange;

- (id) initWithEngine:(Engine*)engine;

- (NSObject<IDataHolder>*) objectAtIndex:(int)index;

- (void) Register;
- (void) Unregister;

- (NSObject*) Get:(Index*)index;
- (void) Set:(Index*)index withObject:(NSObject*)object;

- (Index*) AddComponent:(FastString*)componentName withComponent:(NSObject*)component;
- (void) RemoveComponent:(FastString*)componentName;

@end
