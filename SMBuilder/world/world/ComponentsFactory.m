//
//  ComponentsFactory.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 07.07.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "ComponentsFactory.h"

@implementation ComponentsFactory

+(FastString*) componentNameForString:(NSString*)name
{
    return [FastString Make:name];
}

+(id) blankComponentForName:(FastString*)name
{
    return nil;
}


@end
