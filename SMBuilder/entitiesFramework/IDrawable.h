//
//  IDrawable.h
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Signal1;
@class GameTime;

@protocol IDrawable <NSObject>

@property(nonatomic, readonly) Signal1* DrawOrderChanged;
@property(nonatomic, readonly) Signal1* VisibleChanged;

@property(nonatomic, assign) BOOL Visible;
@property(nonatomic, assign) int DrawOrder;

- (void) LoadGfxContent;
- (void) UnloadGfxContent;

- (void) Draw:(GameTime*)gameTime;

@end
