//
//  SM.m
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "SM.h"

@interface SM()
{
    NSMutableDictionary *descriptions;
    NSMutableDictionary *groups;
}
@end

@implementation SM

- (id)init
{
    self = [super init];
    if (self) {
        descriptions = @{}.mutableCopy;
    }
    return self;
}

-(void) addState:(SMStateDescription*) description
{
    [descriptions setObject:description forKey:description.key];
    NSLog(@"added state for key: %@",description.key);
}
-(void) addTransition:(SMTransition*)transition from:(NSString*)fromKey to:(NSString*)toKey
{
    SMStateDescription *from = descriptions[fromKey];
    SMStateDescription *to = descriptions[toKey];
    if (!from || !to)
        return;
    transition.startPoint = from;
    transition.endPoint = to;
    [from.outerTransitions addObject:transition];
    [from.outerTargets addObject:to.key];
    NSLog(@"added %@ -> %@ transition",from.key, to.key);
}

-(void) addTransition:(SMTransition*)transition
{
    if (!transition.startPoint.key)
        return;
    SMStateDescription *from = descriptions[transition.startPoint.key];
    [from.outerTransitions addObject:transition];
    [from.outerTargets addObject:transition.endPoint.key];
    NSLog(@"added %@ -> %@ transition",from.key, transition.endPoint.key);
}

-(SMStateDescription*) descriptionForKey:(NSString*)key
{
    return descriptions[key];
}

-(SMTransition*) processEntityState:(SMEntity*)state
{
    SMStateDescription *internal = state.stateDescription;
    for (SMTransition *tran in internal.outerTransitions)
    {
        if (tran.completionBlock && tran.completionBlock(state))
        {
            if (!tran.validationBlock || tran.validationBlock(state,tran))
            return tran;
        }
    }
    return nil;
}

-(void) addGroup:(NSString*)groupName
{
    if (!groups) groups = @{}.mutableCopy;
    if (groups[groupName])
    {
        NSLog(@"ERROR:group %@ already exists",groupName);
        return;
    }
    groups[groupName] = @[].mutableCopy;
    
}
-(void) addState:(SMStateDescription*) description toGroup:(NSString*)groupName;
{
    if (!groups[groupName])
        [self addGroup:groupName];
    [groups[groupName] addObject:description];
}

-(NSArray*) addTransition:(SMTransition*)transition
            fromGroup:(NSString*) fromGroupKey
              toState:(NSString*)toKey
{
    SMStateDescription *endPoint = [self descriptionForKey:toKey];
    if (!endPoint)
    {
        NSLog(@"ERROR:there is no state description with key %@",toKey);
        return nil;
    }
    NSMutableArray *resultTrans = [NSMutableArray new];
    for (SMStateDescription *from in groups[fromGroupKey])
    {
        SMTransition *tran = [SMTransition transitionWithBlock:transition.completionBlock];
        tran.startPoint = from;
        tran.endPoint = endPoint;
        tran.onInBlock = transition.onInBlock;
        tran.onOutBlock = transition.onOutBlock;
        tran.event = transition.event;
        tran.completionBlock = transition.completionBlock;
        tran.validationBlock = transition.validationBlock;
        [self addTransition:tran];
        [resultTrans addObject:tran];
    }
    return resultTrans;
}

-(NSArray*) addTransition:(SMTransition*)transition
            fromState:(NSString*)fromKey
              toGroup:(NSString*) toGroupKey
{
    SMStateDescription *startPoint = [self descriptionForKey:fromKey];
    if (!startPoint)
    {
        NSLog(@"ERROR:there is no state description with key %@",fromKey);
        return nil;
    }
    NSMutableArray *resultTrans = [NSMutableArray new];
    for (SMStateDescription *to in groups[toGroupKey])
    {
        SMTransition *tran = [SMTransition transitionWithBlock:transition.completionBlock];
        tran.startPoint = startPoint;
        tran.endPoint = to;
        tran.onInBlock = transition.onInBlock;
        tran.onOutBlock = transition.onOutBlock;
        tran.event = transition.event;
        tran.completionBlock = transition.completionBlock;
        tran.validationBlock = transition.validationBlock;

        [self addTransition:tran];
        [resultTrans addObject:tran];
    }
    return resultTrans;

}

-(NSArray*) addTransition:(SMTransition *)transition
            fromGroup:(NSString*)fromGroupKey
              toGroup:(NSString*)toGroupKey
{
    NSMutableArray *resultTrans = [NSMutableArray new];
    for (SMStateDescription *from in groups[fromGroupKey])
    {
        [resultTrans addObjectsFromArray:[self addTransition:transition fromState:from.key toGroup:toGroupKey]];
    }
    return resultTrans;
}

-(BOOL) isState:(SMStateDescription*) description
        inGroup:(NSString*)group
{
    for (SMStateDescription *to in groups[group])
    {
        if (to == description)
            return YES;
    }
    return NO;
}

-(BOOL) isGroupExists:(NSString*) group
{
    return (groups[group] != nil);
}

-(void) addMultipleStates:(NSArray*)states
{
    for (SMStateDescription *state in states)
    {
        [self addState:state];
    }
}
-(void) addMultipleTransitions:(NSArray*)transitions
{
    for (SMTransition *tran in transitions)
    {
        [self addTransition:tran];
    }
}

-(void) removeTransition:(SMTransition*)transition
{
    
}




@end
