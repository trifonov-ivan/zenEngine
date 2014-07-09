//
//  World.h
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMEntity;
@class SM;
@class Engine;

@interface World : NSObject
{
    NSMutableArray *entities;
    NSMutableDictionary *SMs;
}
@property (nonatomic, assign) Class basicEntityClass;
@property (nonatomic, readwrite) BOOL isCalculatingNow;

-(instancetype) initWithEngine:(Engine*) engine;

-(void) removeEntitiesFromArray:(NSArray*)entitiesToRemove;

-(void) nextStep;

-(void) registerSM: (SM*)sm ForKey:(NSString*)key;

-(SMEntity*) addEntityWithInitialState:(NSString*)key
                   withStateMachineKey:(NSString*)smKey
                        withDataSource:(id)dataSource
                       withEntityClass:(Class)className;

-(SMEntity*) addEntityWithInitialState:(NSString*)key
                   withStateMachineKey:(NSString*)smKey
                        withDataSource:(id)dataSource
                       withEntityClass:(Class)className
                          supressStart:(BOOL)supress;

-(void) invokeEntity:(SMEntity*)entity
        withStateKey:(NSString*)key;

-(BOOL)forceProcessEntity:(SMEntity*)entity
           toStateWithKey:(NSString*)key;

-(void)forceSetEntity:(SMEntity*)entity
       toStateWithKey:(NSString*)key;

-(NSMutableArray *) getEntities;
-(NSMutableDictionary *) getSMs;

-(BOOL) canProcessEvent:(NSString *) event toEntity:(SMEntity*)entity withData:(id) data;
-(BOOL) processEvent:(NSString *) event toEntity:(SMEntity*)entity withData:(id) data;
@end
