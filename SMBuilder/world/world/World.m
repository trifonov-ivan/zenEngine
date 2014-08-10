//
//  World.m
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "World.h"
#import "SMEntity.h"
#import "SM.h"

@interface World()
{
    NSMutableArray *tmpThread;
    NSMutableArray *tmpRemoveThread;
    Engine *componentEngine;
}
@end

@implementation World

- (instancetype)initWithEngine:(Engine *)engine
{
    self = [super init];
    if (self) {
        SMs = @{}.mutableCopy;
        entities = @[].mutableCopy;
        tmpThread = @[].mutableCopy;
        tmpRemoveThread = @[].mutableCopy;
        self.isCalculatingNow = NO;
        componentEngine = engine;
        self.basicEntityClass = [SMEntity class];
    }
    return self;
}

-(void) registerSM: (SM*)sm ForKey:(NSString*)key;
{
    sm.key = key;
    SMs[key] = sm;
}

-(SMEntity*) addEntityWithInitialState:(NSString*)key withStateMachineKey:(NSString*)smKey withDataSource:(id)dataSource withEntityClass:(Class)class supressStart:(BOOL)supress
{
    SM* sm = SMs[smKey];
    SMEntity *entity = nil;
    if (!class)
    {
        entity = [[self.basicEntityClass alloc] initWithEngine:componentEngine];
    }
    else
    {
        entity = [[class alloc] initWithEngine:componentEngine];
    }

    entity.world = self;
    entity.associatedSM = sm;
    entity.dataSource = dataSource;
    entity.invokeData = key;
    if (!supress)
    {
        [entity entityPrepareToStart];
        entity.stateDescription = [sm descriptionForKey:key];
    }
    if (self.isCalculatingNow)
    {
        [tmpThread addObject:entity];
    }
    else
    {
        @synchronized (entities)
        {
            [entities addObject:entity];
        }
    }
    [entity Register];
    return entity;
}

-(void) invokeEntity:(SMEntity*)entity withStateKey:(NSString*)key
{
    [entity entityPrepareToStart];
    entity.stateDescription = [entity.associatedSM descriptionForKey:key];
}

-(SMEntity*) addEntityWithInitialState:(NSString*)key withStateMachineKey:(NSString*)smKey withDataSource:(id)dataSource withEntityClass:(Class)class
{
    return [self addEntityWithInitialState:key withStateMachineKey:smKey withDataSource:dataSource withEntityClass:class supressStart:NO];
}

-(void) removeEntitiesFromArray:(NSArray*)entitiesToRemove
{
    for (SMEntity* entity in entitiesToRemove)
    {
        [entity entityPrepareToRemove];
        [entity Unregister];
    }
    
    if (self.isCalculatingNow)
    {
        [tmpRemoveThread addObjectsFromArray:entitiesToRemove];
    }
    else
    {
        @synchronized (entities)
        {
            [entities removeObjectsInArray:entitiesToRemove];
        }
    }
}

-(BOOL) canProcessEvent:(NSString *) event toEntity:(SMEntity*)entity withData:(id) data
{
    NSArray *transitions = entity.stateDescription.outerTransitions;
    for (SMTransition *tran in transitions)
    {
        if ([tran.event isEqualToString:event])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL) processEvent:(NSString *) event toEntity:(SMEntity*)entity withData:(id) data
{
    NSArray *transitions = entity.stateDescription.outerTransitions;
    NSMutableArray *tmp = @[].mutableCopy;
    for (SMTransition *tran in transitions)
    {
        if ([tran.event isEqualToString:event])
        {
            if (tran.validationBlock && !tran.validationBlock(entity,tran))
                continue;
            if (tran.calculatingEndpoint && !tran.calculatingEndpoint(entity,tran))
                continue;
            
            entity.currentTransition = tran;
            [tmp addObject:entity];
            break;
        }
    }
    if (tmp.count)
    {
        if (data)
        {
            ((SMEntity*)[tmp firstObject]).dataSource = data;
        }
        [self processEntitiesToStates:tmp];
        return YES;
    }
    return NO;
}

-(void) processEntitiesToStates:(NSArray*)entititesArray
{
    for (SMEntity *entity in entititesArray)
    {
        SMTransition *transition = entity.currentTransition;
        if (!transition)
            continue;
        
        if (transition.onOutBlock)
        {
            transition.onOutBlock(entity,transition);
        }
        if (transition.endPoint)
        {
            entity.stateDescription = transition.endPoint;
        }
        else
        {
            entity.stateDescription = transition.calculatingEndpoint(entity,transition);
        }

        if (transition.onInBlock)
        {
            transition.onInBlock(entity,transition);
        }
    }
}

-(void)nextStep
{
    self.isCalculatingNow = YES;
    NSMutableArray *tmp = @[].mutableCopy;
    for (SMEntity *entity in entities)
    {
        SMTransition *transition = [entity.associatedSM processEntityState:entity];
        entity.currentTransition = transition;
        if (transition)
        {
            [tmp addObject:entity];
        }
    }
    
    [self processEntitiesToStates:entities];
    
    self.isCalculatingNow = NO;
    if (tmpThread.count)
    {
        @synchronized (entities)
        {
            [entities addObjectsFromArray:tmpThread];
            [tmpThread removeAllObjects];
        }
    }
    
    if (tmpRemoveThread.count)
    {
        @synchronized (entities)
        {
            [entities removeObjectsInArray:tmpRemoveThread];
            [tmpRemoveThread removeAllObjects];
        }
    }
    self.isCalculatingNow = YES;
    for (SMEntity *entity in entities)
    {
        [entity update];
    }
    self.isCalculatingNow = NO;
    
}

-(void) adjustingEntites
{
    @synchronized (entities)
    {
        [entities addObjectsFromArray:tmpThread];
        [tmpThread removeAllObjects];
    }
}

-(BOOL)forceProcessEntity:(SMEntity*)entity toStateWithKey:(NSString*)key
{
    SMStateDescription *descr = entity.stateDescription;
    SMStateDescription *end = [entity.associatedSM descriptionForKey:key];
    SMTransition *transition = nil;
    for (SMTransition *tran in descr.outerTransitions)
    {
        if (tran.endPoint == end || (tran.calculatingEndpoint && tran.calculatingEndpoint(entity, tran)))
            transition = tran;
    }
    if (transition)
    {
        if (transition.onOutBlock)
        {
            transition.onOutBlock(entity,transition);
        }
        entity.stateDescription = transition.calculatingEndpoint ? transition.calculatingEndpoint(entity, transition) : transition.endPoint;
        if (transition.onInBlock)
        {
            transition.onInBlock(entity,transition);
        }
        return YES;
    }
    return NO;
}

-(void)forceSetEntity:(SMEntity*)entity toStateWithKey:(NSString*)key
{
    SMStateDescription *end = [entity.associatedSM descriptionForKey:key];
    entity.stateDescription = end;
}

-(NSMutableArray *) getEntities
{
    return entities;
}
-(NSMutableDictionary *) getSMs
{
    return SMs;
}


@end
