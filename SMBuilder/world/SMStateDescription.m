//
//  SMStateDescription.m
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "SMStateDescription.h"
#import "SMEntity.h"
#import "SMTransition.h"
#import "SM.h"
@implementation SMStateDescription

- (id)init
{
    self = [super init];
    if (self) {
        self.outerTransitions = [NSMutableArray new];
        self.outerTargets = [NSMutableArray new];
        self.onEnterArray = [NSMutableArray new];
        self.onLeaveArray = [NSMutableArray new];
        self.onUpdateArray = [NSMutableArray new];
    }
    return self;
}


+(instancetype)stateDescriptionForKey:(NSString*)key
{
    SMStateDescription *descr = [[self alloc] init];
    descr.key = key;
    return descr;
}

+(instancetype)stateDescriptionForKey:(NSString*)key fromStateMachine:(SM*)sm
{
    SMStateDescription *descript = [sm descriptionForKey:key];
    if (!descript)
    {
        descript = [self stateDescriptionForKey:key];
        [sm addState:descript];
    }
    return descript;
}

-(void) entityLeaved:(SMEntity *)entity toState:(SMStateDescription*)state;
{
    if (entity.isActive)
    {
        for (CompletionBlock block in self.onLeaveArray)
            block(entity);
    }
}

-(void)entityEntered:(SMEntity*)entity
{
    entity.timeInCurrentState = 0;
    if (entity.isActive)
    {
        for (CompletionBlock block in self.onEnterArray)
            block(entity);
    }
}

-(void) entityUpdated:(SMEntity*)entity
{
    entity.timeInCurrentState++;
    if (entity.isActive)
    {
        for (CompletionBlock block in self.onUpdateArray)
            block(entity);
    }
}

-(instancetype)addMusicalTheme:(NSString*)themeKey
{
    self.musicalTheme = themeKey;
    return self;
}

-(instancetype)addOnEnterBlock:(CompletionBlock)block
{
    [self.onEnterArray addObject: [block copy]];
    return self;
}

-(instancetype)addOnUpdateBlock:(CompletionBlock)block
{
    [self.onUpdateArray addObject: [block copy]];
    return self;
}

-(instancetype)addOnLeaveBlock:(CompletionBlock)block
{
    [self.onLeaveArray addObject: [block copy]];
    return self;
}

//- (void)dealloc
//{
//    NSLog(@"ERROR: state destroyed %@",self.key);
//}

@end
