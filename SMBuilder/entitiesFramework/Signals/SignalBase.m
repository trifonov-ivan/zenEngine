
#import "SignalBase.h"
#import "ListenerNodePool.h"
#import "ListenerNode.h"

#define GET_TARGET_ACTION_KEY(object, selector, block) [NSString stringWithFormat:@"%@%lu%lu", NSStringFromSelector(selector), [(NSObject *)object hash], [(NSObject *)block hash]]

@interface SignalBase()
@property (nonatomic, strong) NSMutableDictionary * nodes;
@property (nonatomic, strong) NSMutableArray *nodesToAdd;
@property (nonatomic, strong) NSMutableArray *nodeKeysToRemove;
@end

@implementation SignalBase
{
    BOOL dispatching;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.nodes = [NSMutableDictionary dictionary];
        self.nodesToAdd = [NSMutableArray array];
        self.nodeKeysToRemove = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc
{
    self.head = nil;
    self.tail = nil;
    self.nodes = nil;
    self.nodesToAdd = nil;
    self.nodeKeysToRemove = nil;
}

- (void)startDispatch
{
    dispatching = YES;
}

- (void)endDispatch
{
    dispatching = NO;
    
    for (NSString *key in self.nodeKeysToRemove)
        [self removeNodeWithKey:key];
    [self.nodeKeysToRemove removeAllObjects];
    
    for (ListenerNode *node in self.nodesToAdd)
    {
        if (self.head == nil)
        {
            self.head = node;
            self.tail = node;
        }
        else
        {
            self.tail.next = node;
            self.tail = node;
        }
    }
    [self.nodesToAdd removeAllObjects];
}

- (void)addListener:(id)target 
             action:(SEL)action
{
    if ([self.nodes objectForKey:GET_TARGET_ACTION_KEY(target, action, nil)] != nil)
        return;
    
    ListenerNode * node = [[ListenerNode alloc] init];
    node.target = target;
    node.listener = action;
    [self.nodes setObject:node forKey:GET_TARGET_ACTION_KEY(target, action, nil)];
    [self addNode:node];
}

- (void)addListenerOnce:(id)target 
                 action:(SEL)action
{
    if ([self.nodes objectForKey:GET_TARGET_ACTION_KEY(target, action, nil)] != nil)
        return;
    
    ListenerNode * node = [[ListenerNode alloc] init];
    node.target = target;
    node.listener = action;
    node.once = YES;
    [self.nodes setObject:node forKey:GET_TARGET_ACTION_KEY(target, action, nil)];
    [self addNode:node];
}

- (void)addBlock:(id)block
{
    return [self addBlock:block withKey:GET_TARGET_ACTION_KEY(nil, nil, block)];
}

- (void)addBlock:(id)block withKey:(NSString *)key
{
    if ([self.nodes objectForKey:key] != nil)
        [self removeBlockWithKey:key];
    
    ListenerNode * node = [[ListenerNode alloc] init];
    node.block = block;
    [self.nodes setObject:node forKey:key];
    [self addNode:node];
}

- (void)addBlockOnce:(id)block
{
    ListenerNode * node = [[ListenerNode alloc] init];
    node.block = block;
	NSString *key = GET_TARGET_ACTION_KEY(nil, nil, node.block);
    node.key = key;
    node.once = YES;
    [self.nodes setObject:node forKey:key];
    [self addNode:node];
}

- (void)addNode:(ListenerNode *)node
{
    if (dispatching) 
    {
        [self.nodesToAdd addObject:node];
    }
    else
    {
        if (self.head == nil)
        {
            self.head = node;
            self.tail = node;
        }
        else
        {
            self.tail.next = node;
            node.previous = self.tail;
            self.tail = node;
        }
    }
}

- (void)removeListener:(id)target 
                action:(SEL)action
{
    NSString *listenerKey = GET_TARGET_ACTION_KEY(target, action, nil);
    if (!dispatching)
        [self removeNodeWithKey:listenerKey];
    else if (listenerKey)
        [self.nodeKeysToRemove addObject:listenerKey];
}

- (void)removeBlockWithKey:(NSString *)key
{
    if (!dispatching)
        [self removeNodeWithKey:key];
    else if (key)
        [self.nodeKeysToRemove addObject:key];
}

- (void)removeNodeWithKey:(NSString *)key
{
    ListenerNode * node = [self.nodes objectForKey:key];
    if (node != nil)
    {
        if ([self.head isEqual:node])
            self.head = self.head.next;
        else if ([self.tail isEqual:node])
		{
            self.tail = self.tail.previous;
			self.tail.next = nil;
		}
        else
        {
            if (node.previous != nil)
                node.previous.next = node.next;
            
            if (node.next != nil)
                node.next.previous = node.previous;
        }
        [self.nodes removeObjectForKey:key];
        
        if ([self.nodesToAdd containsObject:node])
            [self.nodesToAdd removeObject:node];
    }
}

- (void)removeAll
{
    while (self.head != nil)
    {
        ListenerNode * listener = self.head;
        self.head = self.head.next;
        listener.previous = nil;
        listener.next = nil;
    }
    self.tail = nil;
    [self.nodes removeAllObjects];
    [self.nodesToAdd removeAllObjects];
}

@end
