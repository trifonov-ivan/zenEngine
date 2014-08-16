//
//  NodeType.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 29.06.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#ifndef SMBuilder_NodeType_h
#define SMBuilder_NodeType_h

typedef enum { signLT, signMT, signLE, signME, signEQ, signAND, signOR, signMINUS, signPLUS, signMULTIPLY, signDIVIDE, signSET, signIN, signINRANGE, signNOT, signINHERIT, signFUNC } signEnum;

typedef enum {typeMath, typeOperational, typeLeaf, typeFunction} calcNodeType;

typedef struct {
    struct nodeTypeTag *left;
    struct nodeTypeTag *right;
    signEnum sign;
    __unsafe_unretained id value;
} mathNode;

typedef struct {
    __unsafe_unretained NSString *prop;
    struct nodeTypeTag *left;
    __unsafe_unretained id value;
    signEnum sign;
} leafNode;

typedef struct {
    signEnum sign;
} operNode;

typedef struct {
    __unsafe_unretained NSInvocation *funcSEL;
    struct nodeListTag *params;
} funcNode;

typedef struct nodeTypeTag {
    calcNodeType type;
    union {
        mathNode opr;
        leafNode leaf;
        operNode inter;
        funcNode func;
    };
} nodeType;

typedef struct nodeListTag {
    nodeType            *content;
    struct nodeListTag  *first;
    struct nodeListTag  *next;
} nodeList;

#endif
