//
//  SMTransition.h
//  zenApp
//
//  Created by Ivan Trifonov on 07.12.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMStateDescription.h"


#import "SMEntity.h"
typedef void (^TranBlock)(SMEntity *myObj, SMTransition *tran);
typedef SMStateDescription* (^DirectionBlock)(SMEntity *myObj, SMTransition *tran);


@interface SMTransition : NSObject

@property (nonatomic, weak) SMStateDescription *startPoint;
@property (nonatomic, weak) SMStateDescription *endPoint;
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, copy) ValidationBlock validationBlock;


@property (nonatomic, strong) NSString *event;

@property (nonatomic, copy) TranBlock onOutBlock;
@property (nonatomic, copy) TranBlock onInBlock;

@property (nonatomic, copy) DirectionBlock calculatingEndpoint;

+(id) transitionFrom:(SMStateDescription*)from
                  to:(SMStateDescription*)to
           withBlock:(CompletionBlock)block;

+(id) transitionFrom:(SMStateDescription*)from
    toStateFromBlock:(DirectionBlock)undefinedEndpoint
           withBlock:(CompletionBlock)block;

+(id) transitionWithBlock:(CompletionBlock)block;
-(id) addTransitionValidation:(ValidationBlock) validate;
-(id) addOnInBlock:(TranBlock) validate;
-(id) addOnOutBlock:(TranBlock) validate;

-(SMTransition*)setTransitionEvent:(NSString*)event;
@end
