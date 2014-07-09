//
//  PlaneStateDescription.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 06.07.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "PlaneStateDescription.h"
#import "PlaneEntity.h"
#import "SMEffect.h"

@implementation PlaneStateDescription

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.effects = [NSMutableDictionary new];
    }
    return self;
}
-(void)entityEntered:(PlaneEntity *)entity
{
    [super entityEntered:entity];
    for (SMEffect *effect in self.effects.allValues)
    {
        entity.effectMasks[effect.name] = effect;
    }
}
@end
