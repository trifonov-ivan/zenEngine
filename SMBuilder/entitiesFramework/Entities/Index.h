//
//  Index.h
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FastString.h"

@interface Index : NSObject

- (id) initWithIndex:(int)index andWithName:(FastString*)name;

@property(nonatomic, readonly) int ComponentIndex;
@property(nonatomic, readonly, strong) FastString* Name;

@end
