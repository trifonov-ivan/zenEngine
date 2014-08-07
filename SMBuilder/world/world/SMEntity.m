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

-(BOOL) canPassToState:(NSString*) stateKey
{
    return [self.stateDescription.outerTargets containsObject:stateKey];
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


@end
