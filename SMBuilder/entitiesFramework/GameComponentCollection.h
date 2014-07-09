//
//  GameComponentCollection.h
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Signal1;
@class Signal2;

@interface GameComponentCollection : NSObject {
    BOOL _updateableCollectionChanged;
    BOOL _drawableCollectionChanged;
    
    NSMutableArray* _all;
    
    NSMutableArray* _sortedUpdateable;
    NSMutableArray* _sortedDrawable;
}

@property(nonatomic, readonly) Signal1* ComponentAdded;
@property(nonatomic, readonly) Signal2* ComponentRemoved;

- (void) Add:(NSObject*)component;

- (void) Remove:(NSObject*)component;
- (void) Remove:(NSObject*)component shouldDeinitialize:(BOOL)deinitialize;

- (void) RemoveAll:(BOOL)deinitialize;

- (NSArray*) All;

- (NSArray*) Updateable;
- (NSArray*) Drawable;

@end
