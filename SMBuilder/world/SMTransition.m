//
//  SMTransition.m
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "SMTransition.h"

@implementation SMTransition

+(id) transitionFrom:(SMStateDescription*)from
                  to:(SMStateDescription*)to
           withBlock:(CompletionBlock)block
{
    SMTransition *tran = [[SMTransition alloc] init];
    tran.startPoint = from;
    tran.endPoint = to;
    tran.completionBlock = block;
    return tran;
}

+(id) transitionWithBlock:(CompletionBlock)block
{
    SMTransition *tran = [[SMTransition alloc] init];
    tran.completionBlock = block;
    return tran;
}

-(id) addTransitionValidation:(ValidationBlock) validate
{
    self.validationBlock = validate;
    return self;
}

-(id) addOnInBlock:(TranBlock) validate
{
    self.onInBlock = validate;
    return self;
}

-(id) addOnOutBlock:(TranBlock) validate
{
    self.onOutBlock = validate;
    return self;
}


-(void) setEndPoint:(SMStateDescription *)endPoint
{
    _endPoint = endPoint;
    if (!endPoint)
    {
        NSLog(@"there is no endpoint at transition!");
    }
}

-(SMTransition*)setTransitionEvent:(NSString*)event
{
    self.event = event;
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"(%@ -> %@):%@",self.startPoint, self.endPoint, [super description]];
}

@end
