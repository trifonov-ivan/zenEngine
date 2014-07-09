//
//  ZenEffect.h
//  zenApp
//
//  Created by Ivan Trifonov on 09.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMEffect : NSObject

@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) double * data;
@property (nonatomic, strong) NSString *name;

+(SMEffect*)squareEffect:(int)n withName:(NSString*)name fillWithValue:(double)val;
+(SMEffect*)squareEffect:(int)n withName:(NSString*)name withArray:(double*)array;

@end
