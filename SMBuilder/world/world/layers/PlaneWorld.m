//
//  PlaneWorld.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 05.07.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "PlaneWorld.h"

@implementation PlaneWorld

-(instancetype) initWithEngine:(Engine*) engine
{
    self = [super initWithEngine:engine];
    if (self) {
        layers = [NSMutableDictionary new];
    }
    return self;
}

-(PlaneEntity*)addEntityWithInitialState:(NSString *)key
                     withStateMachineKey:(NSString *)smKey
                          withDataSource:(id)dataSource
                         withEntityClass:(Class)class
                         withCoordinates:(int) x
                                        :(int) y
{
    PlaneEntity* entity=(PlaneEntity*)[super addEntityWithInitialState:key withStateMachineKey:smKey withDataSource:dataSource withEntityClass:class];
    entity.x = x;
    entity.y = y;
    [self recalculateFrame];
    return entity;
}

-(PlaneEntity*)addEntityWithInitialState:(NSString *)key
                     withStateMachineKey:(NSString *)smKey
                          withDataSource:(id)dataSource
                         withEntityClass:(Class)class
                         withCoordinates:(int) x
                                        :(int) y
                            supressStart:(BOOL)supress
{
    PlaneEntity* entity=(PlaneEntity*)[super addEntityWithInitialState:key withStateMachineKey:smKey withDataSource:dataSource withEntityClass:class supressStart:YES];
    entity.x = x;
    entity.y = y;
    [self recalculateFrame];
    return entity;
}

-(void) recalculateFrame
{
    frame = CGRectMake(0, 0, 0, 0);
    NSArray *elements = entities.copy;
    for (PlaneEntity *entity in elements)
    {
        if ([entity isKindOfClass:[PlaneEntity class]])
        {
            if (entity.x < frame.origin.x)
                frame.origin.x = entity.x;
            if (entity.y < frame.origin.y)
                frame.origin.y = entity.y;
            if (entity.x > frame.size.width)
                frame.size.width = entity.x;
            if (entity.y > frame.size.height)
                frame.size.height = entity.y;
        }
    }
    frame.size.width -= frame.origin.x-1;
    frame.size.height -= frame.origin.y-1;
}


-(void) registerLayer:(SMLayer*)layer forName:(NSString*)name
{
    layers[name] = layer;
}

-(void) prepareMatrix
{
    NSArray *altEntities = entities.copy;
    for (SMLayer* layer in layers.allValues)
    {
        [layer setUpWithEntities:altEntities forSize:frame];
    }
}

-(void)nextStep
{
    [self prepareMatrix];
    [super nextStep];
}

-(id)valueForEntity:(PlaneEntity*)entity forKey:(NSString*)key
{
    SMLayer *layer = layers[key];
    return [layer valueForEntity:entity];
}

-(SMLayer*)getLayerForKey:(NSString*)key
{
    return layers[key];
}

-(NSArray*)getLayers;
{
    return layers.allValues;
}

@end
