//
//  RandomMacro.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 16.08.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "RandomMacro.h"

@implementation RandomMacro

-(id)invokeWithParams:(NSArray *)params forEntity:(SMEntity *)entity andTransition:(SMTransition *)transition
{
    return @(arc4random() % [params[0] intValue]);
}

+(NSString *)name
{
    return @"random";
}
@end
