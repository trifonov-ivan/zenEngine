//
//  ComponentsFactory.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 07.07.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FastString.h"
@interface ComponentsFactory : NSObject

+(FastString*) componentNameForString:(NSString*)name;
+(id) blankComponentForName:(FastString*)name;

@end
