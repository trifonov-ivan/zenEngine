//
//  GameTime.m
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "GameTime.h"

@implementation GameTime

- (id) initWithTotalTime:(NSTimeInterval)TotalTime andWith:(NSTimeInterval)ElapsedTime {
    if ((self = [super init])) {
        _TotalTime = TotalTime;
        _ElapsedTime = ElapsedTime;
    }
    
    return false;
}

@end
