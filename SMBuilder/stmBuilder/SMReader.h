//
//  SMReader.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 29.06.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"

@interface SMReader : NSObject

@property (nonatomic, strong) World *world;
@property (nonatomic, assign) Class componentsFactoryClass;

+(SMReader*) sharedReader;
-(void) processFile:(NSString*)file;
@end
