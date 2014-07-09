//
//  Filter.m
//  cocos2d-ios
//
//  Created by Andrei Ivanchikov on 11/4/13.
//
//

#import "Filter.h"

@implementation Filter

- (id) initWithMask:(unsigned long long) aMask {
    if ((self = [super init])) {
        self.Mask = aMask;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Filter class]]) {
        Filter* filter = (Filter*)object;
        return filter.Mask == self.Mask;
    }
    
    return false;
}

- (NSUInteger)hash {
    return (NSUInteger)((_Mask >> 32) ^ (_Mask & 0x00000000FFFFFFFF));
}

- (id)copyWithZone:(NSZone *)zone {
    Filter* filter = [[[self class] allocWithZone:zone] initWithMask:self.Mask];
    return filter;
}

@end
