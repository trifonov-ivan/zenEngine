//
//  SMLayer.m
//  zenApp
//
//  Created by Ivan Trifonov on 09.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "SMLayer.h"
#import "SMEffect.h"
@implementation SMLayer

-(void) setUpWithEntities:(NSArray*) entities forSize:(CGRect) basicFrame
{
    frame = basicFrame;
    int w = frame.size.width;
    int h = frame.size.height;
    int x = frame.origin.x;
    int y = frame.origin.y;
    NSString *name = [self name];
    if (size.width != w || size.height != h)
    {
        size = frame.size;
        if (valueArray)
            free(valueArray);
        valueArray = malloc(sizeof(double) * w * h);
    }
    
    for (int i = 0; i <w*h; i++)
        valueArray[i] = 0;

    for (PlaneEntity *entity in entities)
    {
        SMEffect *effect = entity.effectMasks[name];
        if (!effect) continue;

        int ex = entity.x;
        int ey = entity.y;
        int ax = effect.anchorPoint.x;
        int ay = effect.anchorPoint.y;
        int aw = effect.size.width;
        int ah = effect.size.height;
        double *data = effect.data;
        for (int i = 0; i <aw*ah; i++)
        {
            int rx = ex - x - ax + (i % aw);
            int ry = ey - y - ay + (i / aw);
            if (rx < 0 || ry < 0 || rx >= w || ry >= h)
                continue;
            [self setValue:data[i] toIndex:rx + ry*w];
        }
    }
}

-(void) setValue:(double) value toIndex:(int) index
{
    valueArray[index] += value;
}

-(id)valueForEntity:(PlaneEntity*)entity
{
    int w = frame.size.width;
    int x = frame.origin.x;
    int y = frame.origin.y;
    if (!(frame.size.width*frame.size.height))
        return 0;
    int ex = entity.x;
    int ey = entity.y;
    int sx = entity.sx;
    int sy = entity.sy;
    if (sx > 1 || sy > 1)
    {
        double result = 0;
        for (int i = ex; i < ex + sx; i++)
            for (int j = ey; j < ey + sy; j++)
            {
                result += valueArray[(i - x) + (j - y)*w];
            }
        return @(result);
    }
    return @(valueArray[(ex - x) + (ey - y)*w]);
}

-(id) setName:(NSString*)nm
{
    name_ = nm;
    return self;
}

-(NSString*)name
{
    return name_ ? name_ : [[self class] name];
}

+(NSString*)name
{
    return @"";
}

- (void)dealloc
{
    if (valueArray)
        free(valueArray);
}

@end
