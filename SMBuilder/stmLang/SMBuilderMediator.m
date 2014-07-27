//
//  SMBuilderMediator.c
//  SMBuilder
//
//  Created by Ivan Trifonov on 29.06.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#include <stdio.h>
#include "SMBuilderMediator.h"
#import  "SMReader.h"
#import "SMReader+InternalAPI.h"
#import "NodeType.h"

#define STR(A) (A == NULL) ? nil : [NSString stringWithUTF8String:A]

nodeList* listWithParam(nodeType *param)
{
    nodeList *list = (nodeList*)malloc(sizeof(nodeList));
    list->content = param;
    list->first = list;
    list->next = NULL;
    return list;
}

nodeList* addNodeToList(nodeList *listcode, nodeType *param)
{
    nodeList *list = (nodeList*)malloc(sizeof(nodeList));
    list->content = param;
    if (listcode)
    {
        list->first = listcode->first;
        listcode->next = list;
    }
    else
    {
        list->first = list;
    }
    list->next = NULL;
    return list;
}

nodeList* orList(nodeList *first, nodeList *second)
{
    nodeType *orNode = (nodeType*)malloc(sizeof(nodeType));
    orNode->type = typeOperational;
    orNode->inter.sign = signOR;
    nodeList *node = first->first;
    nodeList *firstPoint = first->first;
    while (node->next != NULL)
    {
        node = node-> next;
    }
    nodeList *orListNode = (nodeList*)malloc(sizeof(nodeList));
    orListNode->content = orNode;
    orListNode->first = firstPoint;
    node->next = orListNode;
    node = orListNode;
    node->next = second->first;
    while (node->next != NULL)
    {
        node = node->next;
        node->first = firstPoint;
    }
    return first->first;
}

nodeType* mathCall(int sign, nodeType *leftOperand, nodeType *rightOperand)
{
    nodeType *node = (nodeType*)malloc(sizeof(nodeType));
    node->type = typeMath;
    node->opr.sign = sign;
    node->opr.right = rightOperand;
    node->opr.left = leftOperand;
    return node;
}

nodeType* leafCall(int sign, char *leftOperand, id rightOperand)
{
    nodeType *node = (nodeType*)malloc(sizeof(nodeType));
    node->type = typeLeaf;
    node->leaf.sign = sign;
    node->leaf.prop = __retained(STR(leftOperand));
    node->leaf.value = rightOperand;
    node->leaf.left = NULL;
    return node;
}

nodeType* leafMathCall(int sign, nodeType *leftOperand, id rightOperand)
{
    nodeType *node = (nodeType*)malloc(sizeof(nodeType));
    node->type = typeLeaf;
    node->leaf.sign = sign;
    node->leaf.prop = nil;
    node->leaf.value = rightOperand;
    node->leaf.left = leftOperand;
    return node;
}


void addComponent(char *componentName)
{
    [[SMReader sharedReader] addComponent:STR(componentName)];
}
void removeComponent(char *componentName)
{
    [[SMReader sharedReader] removeComponent:STR(componentName)];
}
void processComponentProps(nodeList *list)
{
    [[SMReader sharedReader] processComponentProps:list];
}

void registerSM(char *name)
{
    [[SMReader sharedReader] registerSM:STR(name)];
}

void processSMProps(nodeList *list)
{
    [[SMReader sharedReader] processSMProps:list];
}

void processStateProps(nodeList *list)
{
    [[SMReader sharedReader] processStateProps:list];
}

void registerLayer(char *name, char *parentClass)
{
    [[SMReader sharedReader] registerLayer:STR(name) forLayerClass:STR(parentClass)];
}
void registerState(char *name, char *parentClass)
{
    [[SMReader sharedReader] registerState:STR(name)
                             forStateClass:STR(parentClass)];
}

void registerStateGroup(NSArray *group, char *name)
{
    [[SMReader sharedReader] registerStateGroup:group forName:STR(name)];
}

void addEffectToLayer(char *name)
{
    [[SMReader sharedReader] addEffectToLayer:STR(name)];
}
void addListToEffect(NSArray* list)
{
    [[SMReader sharedReader] addListToEffect:list];
}
void addSquareEffect(NSNumber* size, NSNumber* fill)
{
    [[SMReader sharedReader] addSquareEffect:size filledWith:fill];
}



void registerTransition(char *from, char *to)
{
    [[SMReader sharedReader] registerTransitionFrom:STR(from)
                                                 to:STR(to)];
}

void processTranProps(nodeList *list)
{
    [[SMReader sharedReader] processTranProps:list];
}
void checkFillingState(stateStateKey key)
{
    [[SMReader sharedReader] checkFillingState:key];
}

void checkTransitionFillingState(transitionStateKey key)
{
    [[SMReader sharedReader] checkTransitionFillingState:key];
}

void setTranEvent(NSString* event)
{
    [[SMReader sharedReader] setTransitionEvent:event];
}

void processClassSetProp(char *prop, char *parentClass)
{
    [[SMReader sharedReader] processClassSetProp:STR(prop)
                                                :STR(parentClass)];
}

BOOL executionResult(nodeList* node)
{
    return [[SMReader sharedReader] executionResult:node];
}
