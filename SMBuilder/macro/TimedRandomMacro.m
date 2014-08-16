//
//  TimedRandomMacro.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 16.08.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "TimedRandomMacro.h"

@implementation TimedRandomMacro

-(id)invokeWithParams:(NSArray *)params forEntity:(SMEntity *)entity andTransition:(SMTransition *)transition
{
    return @(arc4random() % MAX([params[0] intValue], 8 / (entity.timeInCurrentState + 1) + 1));
}

+(NSString *)name
{
    return @"trandom";
}

@end
