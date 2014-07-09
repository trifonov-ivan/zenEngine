//
//  ZenEffect.m
//  zenApp
//
//  Created by Ivan Trifonov on 09.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "SMEffect.h"

@implementation SMEffect


+(SMEffect*)squareEffect:(int)n withName:(NSString*)name fillWithValue:(double)val
{
    SMEffect *effect = [[SMEffect alloc] init];
    effect.name = name;
    effect.anchorPoint = CGPointMake((int)(n-1)/2, (n-1)/2);
    effect.size = CGSizeMake(n, n);
    effect.data = malloc(sizeof(double)*n*n);
    for (int i = 0; i < n*n; i++)
    {
        effect.data[i] = val;
    }
    return effect;
}

+(SMEffect*)squareEffect:(int)n withName:(NSString*)name withArray:(double*)array
{
    SMEffect *effect = [[SMEffect alloc] init];
    effect.name = name;
    effect.anchorPoint = CGPointMake((int)(n-1)/2, (n-1)/2);
    effect.size = CGSizeMake(n, n);
    effect.data = malloc(sizeof(double)*n*n);
    memcpy(effect.data, array, sizeof(double)*n*n);
    return effect;
}

- (void)dealloc
{
    free(self.data);
}
@end
