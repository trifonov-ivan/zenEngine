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

extern int yyparse();
extern char * yytext;
extern int yydebug;
typedef struct yy_buffer_state *YY_BUFFER_STATE;
void yy_switch_to_buffer(YY_BUFFER_STATE);
YY_BUFFER_STATE yy_scan_string (const char *);

@interface SMReader()
{
    SM *actualSM;
    
    SMTransition *actualTran;
    transitionStateKey actualTransitionState;
    NSMutableDictionary *transitions;
    
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
    }
    return self;
}

-(void) processFile:(NSString *)file
{
    if (!self.world || !self.componentsFactoryClass)
    {
        NSAssert(TRUE, @"There is no world to process SM");
    }
    NSString *str = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    ;
    yy_switch_to_buffer(yy_scan_string([str UTF8String]));
//    yydebug = 1;
    yyparse();
}

-(void) registerSM:(NSString*) name
{
    actualSM = self.world.getSMs[name];
    if (!actualSM)
    {
        actualSM = [[SM alloc] init];
        [self.world registerSM:actualSM ForKey:name];
    }
}

-(void) processSMProps:(nodeList*) list
{
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
        SMLayer *layer = [[stClass alloc] init];
        [((PlaneWorld*)self.world) registerLayer:layer forName:name];
    }
}

-(void) registerState:(NSString*) name forStateClass:(NSString*) stateClass
{
    Class stClass = stateClass ? NSClassFromString(stateClass) : basicStateClass;
    if ([actualSM descriptionForKey:name])
    {
        actualState = [actualSM descriptionForKey:name];
        return;
    }
    SMStateDescription* state = [stClass stateDescriptionForKey:name];
    [actualSM addState:state];
    actualState = state;
}

-(void) processStateProps:(nodeList*) list
{
    nodeList *anListObject = list;
    while (anListObject != NULL)
    {
        if (anListObject->content != NULL)
        {
            [self attachNodeProperty:anListObject->content toId:actualState];
        }
        anListObject = anListObject->next;
    }
}

-(void) checkFillingState:(stateStateKey) key
{
    actualStateState = key;
}

-(void) addEffectToLayer:(NSString*) name
{
    actualEffect = [[SMEffect alloc] init];
    actualEffect.name = name;
    ((PlaneStateDescription*)actualState).effects[name] = actualEffect;
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
            return;
        }
        
        if (size > actualEffect.size.width)
        {
            [self replaceSquareArray:actualEffect.size.width :actualEffect.data
                             inArray:size :effect];
            free(actualEffect.data);
            actualEffect.data = effect;
        }
        else
        {
            [self replaceSquareArray:size :effect
                             inArray:actualEffect.size.width :actualEffect.data];
            free(effect);
        }
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

-(void) registerTransitionFrom:(NSString*) from to:(NSString*) to
{
    NSString *stringKey = [NSString stringWithFormat:@"%@-%@",from,to];
    SMTransition *transition = transitions[stringKey];
    if (!transition)
    {
        SMStateDescription *fromState = [actualSM descriptionForKey:from];
        SMStateDescription *toState = [actualSM descriptionForKey:to];
        if (!(fromState && toState))
        {
            NSAssert(TRUE,@"There is no one from states %@ | %@",from, to);
        }
        transition = [SMTransition transitionFrom:fromState to:toState withBlock:nil];
        [actualSM addTransition:transition];
        transitions[stringKey] = transition;
    }
    actualTran = transition;
}

-(void) checkTransitionFillingState:(transitionStateKey) key
{
    actualTransitionState = key;
}

-(void) processTranProps:(nodeList*) list
{
    __block SMReader *wself = self;
    switch (actualTransitionState) {
        case TSK_COMMON:
            actualTran.completionBlock = ^BOOL(SMEntity *obj){
                return [wself executionResult:list :obj :nil];
            };
            break;
        case TSK_VALIDATION:
            actualTran.validationBlock = ^BOOL(SMEntity *obj, SMTransition *tran){
                return [wself executionResult:list :obj :tran];
            };
            break;
        default:
            break;
    }
}

-(void) setTransitionEvent:(NSString*) event
{
    actualTran.event = event;
}

-(void) addComponent:(NSString*) name
{
    actualComponentName = [self.componentsFactoryClass componentNameForString:name];
    actualComponent = [self.componentsFactoryClass blankComponentForName:actualComponentName];
}
-(void) removeComponent:(NSString*) name
{
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
            switch (node->opr.sign) {
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
                        [self setValue:data forKey:node->leaf.prop];
                    }
                    @catch (NSException * e)
                    {
                        @try
                        {
                            [object setValue:data forKey:node->leaf.prop];
                        }
                        @catch (NSException * e)
                        {
                            NSLog(@"key did not exists:%@ for Object:%@",node->leaf.prop,object);
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

-(BOOL) executionResult: (nodeList*) list :(SMEntity*)entity :(SMTransition*)transition
{
    nodeList *anListObject = list;
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
                    
                    @try
                    {
                        currentProp = [entity valueForKey:propName];
                    }
                    @catch (NSException * e)
                    {
                        NSAssert(true,@"value does not exists for key:%@ at transition %@",propName,transition);
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
