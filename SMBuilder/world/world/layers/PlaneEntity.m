//
//  PlaneEntity.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 05.07.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "PlaneEntity.h"
#import "PlaneWorld.h"

@implementation PlaneEntity

-(id) objectForKeyedSubscript:(id)key
{
    return [((PlaneWorld*)self.world) valueForEntity:self forKey:key];
}

-(id)valueForUndefinedKey:(NSString *)key
{
    SMLayer *layer = [((PlaneWorld*)self.world) getLayerForKey:key];
    if (layer)
        return [layer valueForEntity:self];
    return [super valueForUndefinedKey:key];
}

@end
