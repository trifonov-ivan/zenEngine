
#import <Foundation/Foundation.h>
#import "ListenerNode.h"

@interface SignalBase : NSObject

@property (nonatomic, strong) ListenerNode * head;
@property (nonatomic, strong) ListenerNode * tail;

- (void)startDispatch;
- (void)endDispatch;

- (void)addListener:(id)target action:(SEL)action;
- (void)addListenerOnce:(id)target  action:(SEL)action;
- (void)addBlock:(id)block;
- (void)addBlock:(id)block withKey:(NSString *)key;
- (void)addBlockOnce:(id)block;
- (void)addNode:(ListenerNode *)node;

- (void)removeListener:(id)target action:(SEL)action;
- (void)removeBlockWithKey:(NSString *)key;
- (void)removeAll;

@end
