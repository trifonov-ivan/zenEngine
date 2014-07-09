//
//  IGameComponent.h
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FastString;

@protocol IGameComponent <NSObject>

@property(nonatomic, retain) FastString* Id;
@property(nonatomic, assign) BOOL InGame;

- (void) Initialize;
- (void) Deinitialize;

@end
