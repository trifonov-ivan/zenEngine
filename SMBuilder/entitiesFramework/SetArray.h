//
//  SetArray.h
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IArrayHolder.h"

@interface SetArray : NSObject<IArrayHolder> {
    BOOL _dirty;
    NSArray* _entities;
    NSMutableSet* _hash;
}

- (NSArray*) Array;
- (BOOL) Add:(NSObject*)entity;
- (BOOL) Remove:(NSObject*)entity;
- (void) Clear;

@end
