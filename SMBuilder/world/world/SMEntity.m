//
//  SMState.m
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "SMEntity.h"
#import "World.h"
#import "SM.h"
#import "SMTransition.h"
#import "Engine.h"

@implementation SMEntity

- (instancetype)initWithEngine:(Engine *)engine
{
    self = [super initWithEngine:engine];
    if (self) {
        self.isActive = NO;
    }
    return self;
}

-(void) update
{
    [self.stateDescription entityUpdated:self];
}

-(void) processEvent:(NSString*) event withData:(id)data
{
    [self.world processEvent:event toEntity:self withData:data];
}

-(BOOL) canProcessEvent:(NSString*) event
{
    __block SMTransition *transitionForEvent = nil;
    [self.stateDescription.outerTransitions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SMTransition *tran = obj;
        if ([tran.event isEqualToString:event])
        {
            transitionForEvent = tran;
            *stop = YES;
        }
    }];
    return transitionForEvent;
}

-(void) setStateDescription:(SMStateDescription *)stateDescription
{
    if (!stateDescription)
    {
        NSLog(@"ERROR: there is no state description");
    }
    [self.stateDescription entityLeaved:self toState:stateDescription];
    [self makeTransitonActionsFrom:self.stateDescription to:stateDescription];
    _stateDescription = stateDescription;    
    [stateDescription entityEntered:self];
}

-(void) makeTransitonActionsFrom:(SMStateDescription*)from to:(SMStateDescription*)to
{
    if (!self.effectMasks)
    {
        self.effectMasks = @{}.mutableCopy;
    }
}

-(void) entityPrepareToStart
{
    self.isActive = YES;
}
-(void) entityPrepareToRemove
{
    
}

+(instancetype) registerEntity:(SMEntity*) entity FromRepresentation:(NSDictionary*) rep onWorld:(World*)world
{
    if (!entity)
        entity = [world addEntityWithInitialState:rep[@"stateKey"] withStateMachineKey:rep[@"stateMachineKey"] withDataSource:rep[@"dataSource"] withEntityClass:[self class]];
    NSDictionary *components = rep[@"components"];
    
    for (NSString *key in components.allKeys)
    {
        [entity AddComponent:[FastString Make:key] withComponent:components[key]];
    }
    return entity;
}

-(id) entityRepresentation
{
    NSMutableDictionary *components = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *indexList = self.Engine.componentIndexes;
    for (FastString *indexKey in indexList.allKeys)
    {
        NSNumber *indexNum = indexList[indexKey];
        if (indexNum)
        {
        Index *index = [[Index alloc] initWithIndex:[indexNum intValue] andWithName:indexKey];
        id data = [self Get:index];
        if (data)
            components[indexKey.String] = data;
        }
    }
    return @{@"components":components};
}

-(void) storeBackState:(NSString*)key
{
    NSString *tranKey = key ? key : self.currentTransition.startPoint.key;
    if (tranKey)
        [self AddComponent:[FastString Make:@"back"] withComponent:self.currentTransition.startPoint.key];
}

-(void) restoreBackState
{
    NSString *key = (NSString*)[self Get:[self.Engine GetComponentIndex:[FastString Make:@"back"]]];
    if (key)
        [self.world forceSetEntity:self toStateWithKey:key];
    [self RemoveComponent:[FastString Make:@"back"]];
}

-(NSString*)backStateKey
{
   return (NSString*)[self Get:[self.Engine GetComponentIndex:[FastString Make:@"back"]]];
}

@end
