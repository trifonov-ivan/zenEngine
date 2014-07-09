//
//  IUpdatable.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 01.07.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef double ccTime;

@protocol IUpdatable <NSObject>

@property (nonatomic, assign) int updateOrder;

-(void) update:(ccTime)dt;

@end