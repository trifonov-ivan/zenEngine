//
//  PlaneWorld.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 05.07.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "World.h"
#import "PlaneEntity.h"
#import "SMLayer.h"

@interface PlaneWorld : World
{
    NSMutableDictionary *layers;
    CGRect frame;
}

-(PlaneEntity*)addEntityWithInitialState:(NSString *)key
                     withStateMachineKey:(NSString *)smKey
                          withDataSource:(id)dataSource
                         withEntityClass:(Class)class
                         withCoordinates:(int) x
                                        :(int) y;

-(PlaneEntity*)addEntityWithInitialState:(NSString *)key
                     withStateMachineKey:(NSString *)smKey
                          withDataSource:(id)dataSource
                         withEntityClass:(Class)class
                         withCoordinates:(int) x
                                        :(int) y
                            supressStart:(BOOL)supress;

-(id)valueForEntity:(SMEntity*)entity forKey:(NSString*)key;
-(void) registerLayer:(SMLayer*)layer forName:(NSString*)name;
-(NSArray*)getLayers;
-(SMLayer*)getLayerForKey:(NSString*)key;

@end
