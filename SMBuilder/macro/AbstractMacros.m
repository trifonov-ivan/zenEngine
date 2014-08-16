//
//  AbstractMacros.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 16.08.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "AbstractMacros.h"
#import "SMReader.h"
@implementation AbstractMacros

+(NSString*) name
{
    //override this in subclasses
    return nil;
}

-(id)invokeWithParams:(NSArray*)params forEntity:(SMEntity *)entity andTransition:(SMTransition *)transition
{
    NSAssert(FALSE, @"must be overriden");
    return nil;
}
@end
