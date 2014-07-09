//
//  Index.m
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "Index.h"

@implementation Index

- (id) initWithIndex:(int)index andWithName:(FastString*)name {
    if ((self = [super init])) {
        _ComponentIndex = index;
        _Name = name;
    }
    
    return self;
}

@end
