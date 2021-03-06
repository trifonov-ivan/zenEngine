//
//  SMReader.m
//  SMBuilder
//
//  Created by Ivan Trifonov on 29.06.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#import "SMReader.h"
#import "PlaneWorld.h"
#import "SM.h"
#import "SMBuilderMediator.h"
#import "SMStateDescription.h"
#import "NodeType.h"
#import "PlaneStateDescription.h"
#import "ComponentsFactory.h"
#import "SMEntity.h"
#import "AbstractMacros.h"
#import "getSubclasses.h"

extern int yyparse();
extern char * yytext;
extern int yydebug;
typedef struct yy_buffer_state *YY_BUFFER_STATE;
void yy_switch_to_buffer(YY_BUFFER_STATE);
YY_BUFFER_STATE yy_scan_string (const char *);

@interface SMReader()
{
    SM *actualSM;
    
    NSArray *actualTranPool;
    transitionStateKey actualTransitionState;
    NSMutableDictionary *transitions;
    NSMutableDictionary *stateInheritanceMap;

    NSMutableDictionary *macroMap;
    NSMutableArray *macroArray;
    
    SMStateDescription *actualState;
    stateStateKey actualStateState;
    
    SMEffect *actualEffect;
    
    __block id actualComponent;
    __block FastString *actualComponentName;
    
    Class basicStateClass;
}

@property (nonatomic, assign) Class sourceType;
@end


static SMReader *sharedReader = nil;

@implementation SMReader

+(SMReader*) sharedReader
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedReader = [[SMReader alloc] init];
    });
    return sharedReader;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        basicStateClass = [SMStateDescription class];
        transitions = [NSMutableDictionary new];
        stateInheritanceMap = [NSMutableDictionary new];
        // need no to flush it
        macroMap = [NSMutableDictionary new];
        macroArray = [NSMutableArray new];
        [self registerMacroses];
    }
    return self;
}

-(void) flush
{
    actualSM = nil;
    actualTranPool = nil;
    transitions = [NSMutableDictionary new];
    stateInheritanceMap = [NSMutableDictionary new];
    actualState = nil;
    actualEffect = nil;
    actualComponent = nil;
    actualComponentName = nil;
    basicStateClass = [SMStateDescription class];

}

-(NSInvocation*) macroMethodForName:(NSString*) name;
{
    Class macroClass = macroMap[name];
    if (!macroClass)
    {
        NSLog(@"error: unrecognized macros:%@",name);
        return nil;
    }
    NSInvocation *invokation = [NSInvocation invocationWithMethodSignature:[macroClass instanceMethodSignatureForSelector:@selector(invokeWithParams:forEntity:andTransition:)]];
    invokation.selector = @selector(invokeWithParams:forEntity:andTransition:);
    invokation.target = __retained [[macroClass alloc] init];
    return __retained invokation;
}

-(void) registerMacro:(Class) MacroClass
{
    if ([MacroClass name])
    {
        macroMap[ [MacroClass name] ] = MacroClass;
    }
}

-(void) registerMacroses
{
    NSArray *macrosClasses = ClassGetSubclasses([AbstractMacros class]);
    for (Class macrosClass in macrosClasses)
    {
        if (macrosClass != [AbstractMacros class])
        {
            NSLog(@"registering macros class %@ for name %@",macrosClass, [macrosClass name]);
            [self registerMacro:macrosClass];
        }
    }
}

-(void) processFile:(NSString *)file
{
    if (!self.world)
    {
        NSAssert(FALSE, @"There is no world to process SM");
    }
    NSString *str = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    ;
    NSLog(@"readed content with lenght %lud from %@", (unsigned long)str.length, file);
    if (str.length > 0)
    {
        @autoreleasepool {
            yy_switch_to_buffer(yy_scan_string([str UTF8String]));
            yydebug = 1;
            yyparse();            
        }
    }
}

-(void) registerSM:(NSString*) name
{
    NSLog(@"process SM: %@",name);
    actualSM = self.world.getSMs[name];
    if (!actualSM)
    {
        actualSM = [[SM alloc] init];
        [self.world registerSM:actualSM ForKey:name];
        NSLog(@"this SM is absent. create new");
    }
}

-(void) processSMProps:(nodeList*) list
{
    if (!list)
        return;
    nodeList *anListObject = list->first;
    while (anListObject != NULL)
    {
        if (anListObject->content != NULL)
        {
            [self attachNodeProperty:anListObject->content toId:actualSM];
        }
        anListObject = anListObject->next;
    }
}

-(void) registerLayer:(NSString*) name forLayerClass:(NSString*) layer
{
    if ([self.world isKindOfClass:[PlaneWorld class]])
    {
        Class stClass = layer ? NSClassFromString(layer) : [SMLayer class];
        SMLayer *layerInstance = [[stClass alloc] init];
        layerInstance.name = name;
        [((PlaneWorld*)self.world) registerLayer:layerInstance forName:name];
        NSLog(@"registering layer: %@ : %@",name, layer ? layer : @"SMLayer");
    }
}

-(void) registerState:(NSString*) name forStateClass:(NSString*) stateClass
{
    NSAssert(name,@"name should not be nil");
    if ([actualSM descriptionForKey:name])
    {
        NSLog(@"exists");
        actualState = [actualSM descriptionForKey:name];
        return;
    }
    NSLog(@"registering state: %@",name);
    if (stateClass)
        NSLog(@"inherits from %@",stateClass);
    Class stClass = stateClass ? NSClassFromString(stateClass) : basicStateClass;

    SMStateDescription *state = nil;;
    if (!stClass) /* class lookup failed. trying to inherit from exist state*/
    {
        SMStateDescription *baseDescript = [actualSM descriptionForKey:stateClass];
        if (baseDescript)
        {
            if (!stateInheritanceMap[stateClass])
            {
                stateInheritanceMap[stateClass] = [NSMutableArray new];
            }
            state = [[baseDescript class] stateDescriptionForKey:name fromStateMachine:actualSM];
            [stateInheritanceMap[stateClass] addObject:name];
        }
        else
        {
            NSLog(@"no such basic state.");
        }
    }
    else
    {
        state = [stClass stateDescriptionForKey:name fromStateMachine:actualSM];
    }
    actualState = state;
}

-(void) processStateProps:(nodeList*) list
{
    if (!list)
        return;
    nodeList *anListObject = list->first;
    while (anListObject != NULL)
    {
        if (anListObject->content != NULL)
        {
            [self attachNodeProperty:anListObject->content toId:actualState];
            for (NSString *stateName in stateInheritanceMap[actualState.key])
            {
                SMStateDescription *state = [actualSM descriptionForKey:stateName];
                if (state)
                {
                    [self attachNodeProperty:anListObject->content toId:state];
                }
            }
        }
        anListObject = anListObject->next;
    }
}

-(void) registerStateGroup:(NSArray*)group forName:(NSString*)name
{
    if (!name)
        return;
    [actualSM addGroup:name];
    NSLog(@"registered group %@",name);
    for (NSString* stateName in group)
    {
        SMStateDescription *descr = [actualSM descriptionForKey:stateName];
        if (descr)
        {
            [actualSM addState:descr toGroup:name];
            NSLog(@"added state %@",stateName);
        }
        else
        {
            NSLog(@"(!) state %@ not registered",stateName);
        }
    }
}


-(void) checkFillingState:(stateStateKey) key
{
    actualStateState = key;
}

-(void) addEffectToLayer:(NSString*) name
{
    NSLog(@"adding effect to layer %@",name);
    actualEffect = [[SMEffect alloc] init];
    actualEffect.name = name;
    ((PlaneStateDescription*)actualState).effects[name] = actualEffect;
    for (NSString *stateName in stateInheritanceMap[actualState.key])
    {
        SMStateDescription *state = [actualSM descriptionForKey:stateName];
        if (state)
        {
            ((PlaneStateDescription*)state).effects[name] = actualEffect;
        }
    }

}

-(void) addListToEffect:(NSArray*) list
{
    int size = sqrt(list.count);
    if (size)
    {
        double *effect = malloc(sizeof(double)*size*size);
        for (int i = 0; i < size * size; i++)
        {
            effect[i] = [list[i] doubleValue];
        }
        if (!actualEffect.size.width)
        {
            actualEffect.data = effect;
            actualEffect.size = CGSizeMake(size, size);
            actualEffect.anchorPoint = CGPointMake((int)(size-1)/2, (size-1)/2);
            return;
        }
        
        if (size > actualEffect.size.width)
        {
            [self replaceSquareArray:actualEffect.size.width :actualEffect.data
                             inArray:size :effect];
            free(actualEffect.data);
            actualEffect.data = effect;
            actualEffect.size = CGSizeMake(size, size);
        }
        else
        {
            [self replaceSquareArray:size :effect
                             inArray:actualEffect.size.width :actualEffect.data];
            free(effect);
        }
        actualEffect.anchorPoint = CGPointMake((int)(actualEffect.size.width-1)/2, (actualEffect.size.width-1)/2);
    }
}

-(void) replaceSquareArray:(int) a :(double*)array inArray:(int) b :(double*)arrayb
{
    int t = (b - a)/2;
    for (int i = t; i < t + a; i++)
        for (int j = t; j < t + a; j++)
    {
        arrayb[i * b + j] = array[(i - t) * a + (j - t)];
    }
}

-(void) addSquareEffect:(NSNumber*) size filledWith:(NSNumber*) fill
{
    NSMutableArray *array =  [NSMutableArray new];
    for (int i = 0; i < [size intValue]*[size intValue]; i++)
    {
        [array addObject:fill];
    }
    [self addListToEffect:array];
}

-(void) makeTransitionBack:(SMTransition*) tran
{
    tran.calculatingEndpoint = ^SMStateDescription*(SMEntity *entity, SMTransition *tran){
        return [entity.associatedSM descriptionForKey:[entity backStateKey]];
    };
}

-(void) registerTransitionFrom:(NSString*) from to:(NSString*) to
{
    NSLog(@"%@ -> %@",from,to);
    NSString *stringKey = [NSString stringWithFormat:@"%@-%@",from,to];
    SMTransition *transition = transitions[stringKey];
    if (!transition)
    {
        transition = [[SMTransition alloc] init];
        BOOL fromGroup = [actualSM isGroupExists:from];
        BOOL toGroup = [actualSM isGroupExists:to];
        if (fromGroup && toGroup)
        {
            actualTranPool = [actualSM addTransition:transition fromGroup:from toGroup:to];
        } else if (fromGroup && !toGroup)
        {
            if ([to isEqualToString:@"back"])
            {
                [self makeTransitionBack:transition];
            }
            else
            {
                transition.endPoint = [actualSM descriptionForKey:to];
            }
            actualTranPool = [actualSM addTransition:transition fromGroup:from];
        } else if (!fromGroup && toGroup)
        {
            transition.startPoint = [actualSM descriptionForKey:to];
            actualTranPool = [actualSM addTransition:transition toGroup:to];
        } else
        {
            SMStateDescription *fromState = [actualSM descriptionForKey:from];
            if (![to isEqualToString:@"back"])
            {
                SMStateDescription *toState = [actualSM descriptionForKey:to];
                if (!(fromState && toState))
                {
                    NSAssert(TRUE,@"There is no one from states %@ | %@",from, to);
                }
                transition = [SMTransition transitionFrom:fromState to:toState withBlock:nil];
            }
            else
            {
                transition = [SMTransition transitionFrom:fromState to:nil withBlock:nil];
                [self makeTransitionBack:transition];
            }
            [actualSM addTransition:transition];
            transitions[stringKey] = transition;
            actualTranPool = @[transition];
        }
    }
}

-(void) checkTransitionFillingState:(transitionStateKey) key
{
    actualTransitionState = key;
}

-(void) processTranProps:(nodeList*) list
{
    if (!list)
        return;
    __block nodeList *blockList = list;
    __block SMReader *wself = self;
    switch (actualTransitionState) {
        case TSK_COMMON:
            for (SMTransition *actualTran in actualTranPool)
            {
                actualTran.completionBlock = ^BOOL(SMEntity *obj){
                    return [wself executionResult:blockList :obj :nil];
                };
            }
            break;
        case TSK_VALIDATION:
            for (SMTransition *actualTran in actualTranPool)
            {
                actualTran.validationBlock = ^BOOL(SMEntity *obj, SMTransition *tran){
                    return [wself executionResult:blockList :obj :tran];
                };
            }
            break;
        default:
            break;
    }
}

-(void) setTransitionEvent:(NSString*) event
{
    NSLog(@"fired on Event: %@",event);
    for (SMTransition *actualTran in actualTranPool)
    {
        actualTran.event = event;
    }
}

-(void) addComponent:(NSString*) name
{
    NSLog(@"add component with name %@",name);
    actualComponentName = [FastString Make:name];
    actualComponent = [self.componentsFactoryClass blankComponentForName:actualComponentName];
}
-(void) removeComponent:(NSString*) name
{
    NSLog(@"remove component with name %@",name);
    switch (actualStateState) {
        case SSK_ENTER:
        {
            [actualState.onEnterArray addObject:^BOOL(SMEntity *myObj){
                [myObj RemoveComponent:[FastString Make:name]];
                return YES;
            }];
        }
            break;
        case SSK_EXIT:
        {
            [actualState.onLeaveArray addObject:^BOOL(SMEntity *myObj){
                [myObj RemoveComponent:[FastString Make:name]];
                return YES;
            }];
        }
            break;
            
        default:
            break;
    }

}

-(void) processComponentProps:(nodeList*) list
{
    if (!list)
        return;
    nodeList *anListObject = list->first;
    if (anListObject && !anListObject->next && !actualComponent)
    {
        actualComponent = anListObject->content->leaf.value;
    }
    else
    {
        if (!actualComponent)
        {
            actualComponent = [[NSMutableDictionary alloc] init];
        }
        
        while (anListObject != NULL)
        {
            if (anListObject->content != NULL)
            {
                [self attachNodeProperty:anListObject->content toId:actualComponent];
            }
            anListObject = anListObject->next;
        }
    }
    [self finalizeComponent];
}

-(void) finalizeComponent
{
    __block FastString *name = actualComponentName;
    __block id component = actualComponent;
    switch (actualStateState) {
        case SSK_ENTER:
        {
            [actualState.onEnterArray addObject:^BOOL(SMEntity *myObj){
                [myObj AddComponent:name withComponent:component];
                return YES;
            }];
        }
            break;
        case SSK_EXIT:
        {
            [actualState.onLeaveArray addObject:^BOOL(SMEntity *myObj){
                [myObj AddComponent:name withComponent:component];
                return YES;
            }];
        }
            break;
            
        default:
            break;
    }
}

-(void) attachNodeProperty:(nodeType*) node toId:(id) object
{
    id data = nil;
    switch (node->type) {
        case typeLeaf:
        {
            switch (node->leaf.sign) {
                case signINHERIT:
                {
                    data = NSClassFromString(node->leaf.value);
                    if (!data)
                    {
                        NSLog(@"there is no source class %@ for property %@",node->leaf.value, node->leaf.prop);
                        break;
                    }
                }
                case signEQ:
                {
                    data = data ? data : node->leaf.value;
                    @try
                    {
                        NSLog(@"set value: %@ for key: %@",data, node->leaf.prop);
                        [object setValue:data forKey:node->leaf.prop];
                    }
                    @catch (NSException * e)
                    {
                        NSLog(@"key did not exists:%@ for Object:%@",node->leaf.prop,object);
                        @try
                        {
                            NSLog(@"set value: %@ for key: %@",data, node->leaf.prop);
                            [self setValue:data forKey:node->leaf.prop];
                        }
                        @catch (NSException * e)
                        {
                            NSLog(@"failed. No such global property");
                        }
                    }
                }
                default:
                    break;
            }
        }
        break;
            
        default:
            break;
    }
}

-(id) mathExpressionResult: (nodeType *) node :(SMEntity*)entity :(SMTransition*)transition
{
    switch (node->type) {
        case typeLeaf:
        {
            NSString *propName = node->leaf.prop;
            if (!propName)
                return node->leaf.value;
            
            @try
            {
                id currentProp = [entity valueForKey:propName];
                return currentProp;
            }
            @catch (NSException * e)
            {
                NSAssert(true,@"value does not exists for key:%@ at transition %@",propName,transition);
                return nil;
            }
        }
            break;
        case typeFunction:
        {
            NSInvocation *invocation = node->func.funcSEL;
            nodeList *list = node->func.params;
            NSMutableArray *params = [[NSMutableArray alloc] init];
            if (list)
            {
                list = list->first;
                while (list) {
                    id result = [self mathExpressionResult:list->content :entity :transition];
                    NSAssert (result, @"function params must exists!");
                    [params addObject:result];
                    list = list -> next;
                }
            }
            [invocation setArgument:&params atIndex:2];
            [invocation setArgument:&entity atIndex:3];
            [invocation setArgument:&transition atIndex:4];
            [invocation retainArguments];
            [invocation invoke];
            id invocationResult = nil;
            [invocation getReturnValue:&invocationResult];
            node->opr.value = invocationResult;
            return invocationResult;
        }
            break;
        case typeMath:
        {
            switch (node->opr.sign) {
//                case signFUNC:
//                {
//                    nodeType *source = node->opr.left;
//                    if ([source->leaf.value isKindOfClass:[NSNumber class]])
//                    {
//                        int limitConst = [source->leaf.value intValue];
//                        node->opr.value = __retained @(arc4random()%limitConst);
//                    }
//                    if ([source->leaf.value isKindOfClass:[NSArray class]])
//                    {
//                        NSArray *array = source->leaf.value;
//                        int limitConst = [array[0] intValue];
//                        int type = [array[1] intValue];
//                        if (!type)
//                            type = 8;
//                        node->opr.value = __retained @(arc4random() % (MAX(type,(limitConst / (entity.timeInCurrentState + 1) + 1))));
//                    }
//                }
                    break;
                case signPLUS:
                {
                    NSNumber *left = [self mathExpressionResult:node->opr.left :entity :transition];
                    NSNumber *right = [self mathExpressionResult:node->opr.right :entity :transition];
                    node->opr.value = __retained @([left doubleValue] + [right doubleValue]);
                }
                    break;
                case signMINUS:
                {
                    NSNumber *left = [self mathExpressionResult:node->opr.left :entity :transition];
                    NSNumber *right = [self mathExpressionResult:node->opr.right :entity :transition];
                    node->opr.value = __retained @([left doubleValue] - [right doubleValue]);
                }
                    break;
                case signMULTIPLY:
                {
                    NSNumber *left = [self mathExpressionResult:node->opr.left :entity :transition];
                    NSNumber *right = [self mathExpressionResult:node->opr.right :entity :transition];
                    node->opr.value = __retained @([left doubleValue] * [right doubleValue]);
                }
                    break;
                case signDIVIDE:
                {
                    NSNumber *left = [self mathExpressionResult:node->opr.left :entity :transition];
                    NSNumber *right = [self mathExpressionResult:node->opr.right :entity :transition];
                    node->opr.value = __retained @([left doubleValue] / [right doubleValue]);
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    return node->opr.value;
}

-(BOOL) executionResult: (nodeList*) list :(SMEntity*)entity :(SMTransition*)transition
{
    if (!list)
        return NO;
    nodeList *anListObject = list->first;
    BOOL globalResult = NO;
    BOOL localResult = YES;
    BOOL inverseResult;
    while (anListObject != NULL)
    {
        inverseResult = NO;
        nodeType *node = anListObject->content;
    reswitch: //oh god NOOOOOOOOOOOO
        if (node != NULL)
        {
            switch (node->type) {
                case typeOperational:
                {
                    switch (node->inter.sign) {
                        case signOR:
                            if (localResult)
                                return YES;
                            globalResult |= localResult;
                            localResult = YES;
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case typeMath:
                {
                    switch (node->opr.sign) {
                        case signNOT:
                            inverseResult = YES;
                            node = node->opr.left;
                            goto reswitch;//oh god NOOOOOOOOOOOO
                            break;
                        default:
                            break;
                    }
                }
                    break;
                    
                case typeLeaf:
                {
                    BOOL currentResult;
                    NSNumber *currentProp;
                    //TODO: need to totally investigate at props methods
                    NSString *propName = node->leaf.prop;
                    if (!propName)
                    {
                        currentProp = [self mathExpressionResult:node->leaf.left :entity :transition];
                    }
                    else
                    {
                        @try
                        {
                            currentProp = [entity valueForKey:propName];
                        }
                        @catch (NSException * e)
                        {
                            NSAssert(true,@"value does not exists for key:%@ at transition %@",propName,transition);
                        }
                    }
                    id val = node->leaf.value;
                    switch (node->leaf.sign) {
                        case signEQ:
                        {
                            currentResult = [currentProp isEqualToNumber:val];
                        }
                            break;
                        case signIN:
                        {
                            currentResult = [val containsObject:currentProp];
                        }
                            break;
                        case signINRANGE:
                        {
                            currentResult = ([val[0] doubleValue] <= [currentProp doubleValue])
                                            && ([val[1] doubleValue] >= [currentProp doubleValue]);
                        }
                            break;
                        case signLT:
                        {
                            currentResult = ([currentProp doubleValue] < [val doubleValue]);
                        }
                            break;
                        case signMT:
                        {
                            currentResult = ([currentProp doubleValue] > [val doubleValue]);
                        }
                            break;
                        case signLE:
                        {
                            currentResult = ([currentProp doubleValue] <= [val doubleValue]);
                        }
                            break;
                        case signME:
                        {
                            currentResult = ([currentProp doubleValue] >= [val doubleValue]);
                        }
                            break;
                        
                        default:
                            break;
                    }
                    localResult = localResult & (inverseResult ^ currentResult);
                }
                    break;
                    
                default:
                    break;
            }
        }
        anListObject = anListObject->next;
    }
    globalResult |= localResult;
    return globalResult;
}


/*predefined setters*/
#pragma mark predefined setters
-(void)setSourceType:(Class)sourceType
{
    _sourceType = sourceType;
    self.world.basicEntityClass = _sourceType;
}

-(void) setStateType:(Class) stateType
{
    basicStateClass = stateType;
}
@end
