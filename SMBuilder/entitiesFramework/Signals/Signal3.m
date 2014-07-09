
#import "Signal3.h"
#import <objc/message.h>

@implementation Signal3

- (void)dispatchWithObject:(id)object1
                withObject:(id)object2
                withObject:(id)object3
{
    [super startDispatch];
    ListenerNode * node = nil;
    for (node = super.head; node != nil; node = node.next) 
    {
        if (node.target)
        {
            objc_msgSend(node.target, node.listener, object1, object2, object3);
            if(node.once)
                [super removeListener:node.target action:node.listener];
        }
        else if (node.block)
        {
            void(^block)(id, id, id) = (void(^)(id, id, id))node.block;
            block(object1, object2, object3);
            if (node.once)
                [super removeBlockWithKey:node.key];
        }
    }
    [super endDispatch];
}

@end
