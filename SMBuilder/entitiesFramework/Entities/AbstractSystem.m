//
//  AbstractSystem.m
//  sloto_objc
//
//  Created by Andrei Ivanchikov on 11/5/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "AbstractSystem.h"
#import "Engine.h"
#import "Signal1.h"

@implementation AbstractSystem
@synthesize updateOrder;

- (id) initWithEngine:(Engine*)engine {
    if ((self = [super init])) {
        self.Engine = engine;
        _ActiveChanged = [[Signal1 alloc] init];
    }
    
    return self;
}

- (void) Register {
	_Active = YES;
    [self.Engine.SystemCollection addObject:self];
}

- (void) Unregister {
    [self.Engine.SystemCollection removeObject:self];
}

- (void) setActive:(BOOL)Active {
    if (_Active != Active) {
        _Active = Active;
        [_ActiveChanged dispatchWithObject:self];
    }
}

- (void)update:(ccTime)time {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString*) systemKey
{
	return [[self class] systemKey];
}

+ (NSString*) systemKey
{
	return NSStringFromClass(self);
}

@end
