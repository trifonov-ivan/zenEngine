//
//  GameComponent.h
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IGameComponent.h"
#import "IUpdateable.h"

@class FastString;
@class Game;

@interface GameComponent : NSObject<IGameComponent, IUpdateable> {
}

- (id) initWithGame:(Game*)game;

@property(nonatomic, readonly, strong) Game* Game;

@property(nonatomic, readonly) BOOL IsInitialized;
@property(nonatomic, readonly) NSMutableDictionary* Actions;

@property(nonatomic, strong) FastString* Id;
@property(nonatomic, assign) BOOL InGame;

@property(nonatomic, assign) BOOL Active;
@property(nonatomic, assign) int UpdateOrder;

@property(nonatomic, readonly) Signal1* UpdateOrderChanged;
@property(nonatomic, readonly) Signal1* ActiveChanged;

@end
