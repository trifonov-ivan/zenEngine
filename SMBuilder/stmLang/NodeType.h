//
//  NodeType.h
//  SMBuilder
//
//  Created by Ivan Trifonov on 29.06.14.
//  Copyright (c) 2014 Ivan Trifonov. All rights reserved.
//

#ifndef SMBuilder_NodeType_h
#define SMBuilder_NodeType_h

typedef enum { signLT, signMT, signLE, signME, signEQ, signAND, signOR, signMINUS, signPLUS, signMULTIPLY, signDIVIDE, signSET, signIN, signINRANGE, signNOT, signINHERIT } signEnum;

typedef enum {typeMath, typeOperational, typeLeaf} calcNodeType;

typedef struct {
    struct nodeTypeTag *left;
    struct nodeTypeTag *right;
    signEnum sign;
} mathNode;

typedef struct {
    __unsafe_unretained NSString *prop;
    __unsafe_unretained id value;
    signEnum sign;
} leafNode;

typedef struct {
    signEnum sign;
} operNode;


typedef struct nodeTypeTag {
    calcNodeType type;
    union {
        mathNode opr;
        leafNode leaf;
        operNode inter;
    };
} nodeType;

typedef struct nodeListTag {
    nodeType            *content;
    struct nodeListTag  *first;
    struct nodeListTag  *next;
} nodeList;

#endif
