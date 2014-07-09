
#import "ListenerNodePool.h"

@implementation ListenerNodePool
{
    ListenerNode * tail;
    ListenerNode * cacheTail;
}

- (ListenerNode *)get
{
    if(tail != nil)
    {
        ListenerNode * node = tail;
        tail = tail.previous;
        node.previous = nil;
        return node;
    }
    else
    {
        return [[ListenerNode alloc] init];
    }
}

- (void)dispose:(ListenerNode *)node
{
    node.listener = nil;
    node.target = nil;
    node.block = nil;
    node.once = NO;
    node.next = nil;
    node.previous = tail;
    tail = node;
}

- (void)cache:(ListenerNode *)node
{
    node.listener = nil;
    node.target = nil;
    node.block = nil;
    node.previous = cacheTail;
    cacheTail = node;
}

- (void)releaseCache
{
    while (cacheTail != nil) 
    {
        ListenerNode * node = cacheTail;
        cacheTail = node.previous;
        node.next = nil;
        node.previous = tail;
        tail = node;
    }
}

@end
