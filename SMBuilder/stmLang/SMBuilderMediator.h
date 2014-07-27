//
//  SMBuilderMediator.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 29.06.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#ifndef SMBuilder_SMBuilderMediator_h
#define SMBuilder_SMBuilderMediator_h

#include "NodeType.h"

typedef enum {SSK_COMMON, SSK_ENTER, SSK_EXIT} stateStateKey;
typedef enum {TSK_COMMON, TSK_VALIDATION} transitionStateKey;


void registerSM(char *name);
void processSMProps(nodeList *list);
void processStateProps(nodeList *list);
void processTranProps(nodeList *list);
void setTranEvent(NSString* event);

void registerLayer(char *name, char *parentClass);

void registerState(char *name, char *parentClass);
void checkFillingState(stateStateKey key);

void addEffectToLayer(char *name);
void addListToEffect(NSArray* list);
void addSquareEffect(NSNumber* size, NSNumber* fill);

void registerTransition(char *from, char *to);
void checkTransitionFillingState(transitionStateKey key);

void addComponent(char *componentName);
void removeComponent(char *componentName);
void processComponentProps(nodeList *list);
void processClassSetProp(char *prop, char *parentClass);

nodeList* listWithParam(nodeType *param);
nodeList* addNodeToList(nodeList *listcode, nodeType *param);

nodeList* orList(nodeList *first, nodeList *second);

nodeType* mathCall(int sign, nodeType *leftOperand, nodeType *rightOperand);
nodeType* leafCall(int sign, char *leftOperand, id rightOperand);
nodeType* leafMathCall(int sign, nodeType *leftOperand, id rightOperand);

BOOL executionResult(nodeList* node);
#endif
