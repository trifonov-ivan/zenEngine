//
//  GameTime.h
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameTime : NSObject

- (id) initWithTotalTime:(NSTimeInterval)TotalTime andWith:(NSTimeInterval)ElapsedTime;

@property(nonatomic, assign) NSTimeInterval TotalTime;
@property(nonatomic, assign) NSTimeInterval ElapsedTime;

@end
