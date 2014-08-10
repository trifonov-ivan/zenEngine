//
//  SMState.h
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMStateDescription.h"
#import "Entity.h"

@class World;
@class SM;
@class SMTransition;
@interface SMEntity : Entity

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, strong) NSMutableDictionary *effectMasks;
@property (nonatomic, weak) SMTransition *currentTransition;
@property (nonatomic, weak) World *world;
@property (nonatomic, weak) SM* associatedSM;
@property (nonatomic, strong) SMStateDescription *stateDescription;
@property (nonatomic, strong) id dataSource;
@property (nonatomic, assign) int timeInCurrentState;
@property (nonatomic, strong) id invokeData;

-(void) update;
-(void) processEvent:(NSString*) event withData:(id) data;
-(void) makeTransitonActionsFrom:(SMStateDescription*)from to:(SMStateDescription*)to;
-(void) entityPrepareToStart;
-(void) entityPrepareToRemove;
-(BOOL) canProcessEvent:(NSString*) event;

+(instancetype) registerEntity:(SMEntity*) entity FromRepresentation:(id) representation onWorld:(World*)world;
-(id) entityRepresentation;

-(void) storeBackState:(NSString*)key;
-(void) restoreBackState;
-(NSString*)backStateKey;

@end
