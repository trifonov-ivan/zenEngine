//
//  SMReader.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 29.06.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"
#import "NodeType.h"
#import "SMBuilderMediator.h"
@class SMTransition;

@interface SMReader : NSObject

@property (nonatomic, strong) World *world;
@property (nonatomic, assign) Class componentsFactoryClass;

-(void) registerSM:(NSString*) name;
-(void) processSMProps:(nodeList*) list;

-(void) registerLayer:(NSString*) name forLayerClass:(NSString*) layer;

-(void) registerState:(NSString*) name forStateClass:(NSString*) stateClass;
-(void) processStateProps:(nodeList*) list;
-(void) registerStateGroup:(NSArray*)group forName:(NSString*)name;

-(void) checkFillingState:(stateStateKey) key;
-(void) addEffectToLayer:(NSString*) name;
-(void) addListToEffect:(NSArray*) list;
-(void) addSquareEffect:(NSNumber*) size filledWith:(NSNumber*) fill;


-(void) registerTransitionFrom:(NSString*) from to:(NSString*) to;
-(void) checkTransitionFillingState:(transitionStateKey) key;
-(void) processTranProps:(nodeList*) list;
-(void) setTransitionEvent:(NSString*) event;

-(void) addComponent:(NSString*) name;
-(void) removeComponent:(NSString*) name;
-(void) processComponentProps:(nodeList*) list;

-(BOOL) executionResult: (nodeList*) list :(SMEntity*)entity :(SMTransition*)transition;

-(NSInvocation*) macroMethodForName:(NSString*) name;
-(void) registerMacro:(Class) MacroClass;

+(SMReader*) sharedReader;
-(void) processFile:(NSString*)file;
-(void) flush;
@end
