//
//  SMStateDescription.h
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SMEntity;
@class SMTransition;
@class SM;

typedef BOOL (^CompletionBlock)(SMEntity *myObj);
typedef BOOL (^ValidationBlock)(SMEntity *myObj, SMTransition *tran);

@interface SMStateDescription : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSMutableArray *outerTransitions;
@property (nonatomic, strong) NSMutableArray *outerTargets;
@property (nonatomic, strong) NSString *musicalTheme;
@property (nonatomic, strong) NSMutableArray *onEnterArray;
@property (nonatomic, strong) NSMutableArray *onUpdateArray;
@property (nonatomic, strong) NSMutableArray *onLeaveArray;


+(instancetype)stateDescriptionForKey:(NSString*)key;
+(instancetype)stateDescriptionForKey:(NSString*)key fromStateMachine:(SM*)sm;
-(instancetype)addMusicalTheme:(NSString*)themeKey;
-(instancetype)addOnEnterBlock:(CompletionBlock)block;
-(instancetype)addOnUpdateBlock:(CompletionBlock)block;
-(instancetype)addOnLeaveBlock:(CompletionBlock)block;

-(void) entityUpdated:(SMEntity*)entity;
-(void) entityEntered:(SMEntity*)entity;
-(void) entityLeaved:(SMEntity *)entity toState:(SMStateDescription*)state;
@end
