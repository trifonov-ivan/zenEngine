//
//  AbstractMacros.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 16.08.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMEntity.h"
#import "SMTransition.h"

@interface AbstractMacros : NSObject

+(NSString*)name;
-(id)invokeWithParams:(NSArray*)params forEntity:(SMEntity*)entity andTransition:(SMTransition*)transition;

@end
