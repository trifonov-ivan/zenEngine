//
//  FAbsMacro.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 16.08.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "FAbsMacro.h"

@implementation FAbsMacro

-(id)invokeWithParams:(NSArray *)params forEntity:(SMEntity *)entity andTransition:(SMTransition *)transition
{
    return @(fabs([params[0] doubleValue]));
}

+(NSString *)name
{
    return @"abs";
}

@end
