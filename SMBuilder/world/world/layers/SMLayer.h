//
//  SMLayer.h
//  zenApp
//
//  Created by Ivan Trifonov on 09.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMEffect.h"
#import "PlaneEntity.h"

@interface SMLayer : NSObject
{
    double *valueArray;
    CGSize size;
    CGRect frame;
    NSString *name_;
}
-(void) setUpWithEntities:(NSArray*) entities forSize:(CGRect) basicFrame;
-(void) setValue:(double) value toIndex:(int) index;
-(id)valueForEntity:(PlaneEntity*)entity;
-(id) setName:(NSString*)nm;
-(NSString*)name;

@end
