//
//  SM.h
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMStateDescription.h"
#import "SMEntity.h"
#import "SMTransition.h"
@interface SM : NSObject

@property (nonatomic, strong) NSString *key;

-(void) addState:(SMStateDescription*) description;

-(void) addTransition:(SMTransition*)transition from:(NSString*)fromKey to:(NSString*)toKey;
-(void) addTransition:(SMTransition*)transition;

-(void) addMultipleStates:(NSArray*)states;
-(void) addMultipleTransitions:(NSArray*)transitions;

-(void) addGroup:(NSString*)groupName;
-(void) addState:(SMStateDescription*) description toGroup:(NSString*)groupName;
-(void) addTransition:(SMTransition*)transition
            fromGroup:(NSString*) fromGroupKey
              toState:(NSString*)toKey;


-(void) addTransition:(SMTransition*)transition
              fromState:(NSString*)fromKey
                toGroup:(NSString*) toGroupKey;

-(BOOL) isState:(SMStateDescription*) description
        inGroup:(NSString*)group;
//TODO: sometime need to make this
//-(void) addTransition:(SMTransition*)transition
//            fromGroup:(NSString*) fromGroupKey
//              toGroup:(NSString*) toGroupKey;
//
//-(void) removeTransition:(SMTransition*)transition;


-(SMStateDescription*) descriptionForKey:(NSString*)key;
-(SMTransition*) processEntityState:(SMEntity*)state;

@end
