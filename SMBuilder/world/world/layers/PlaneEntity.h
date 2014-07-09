//
//  PlaneEntity.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 05.07.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "SMEntity.h"

@interface PlaneEntity : SMEntity

@property (nonatomic, readwrite) int x,y;
@property (nonatomic, readwrite) int sx,sy;

-(id) objectForKeyedSubscript:(id)key;
@end
