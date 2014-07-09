
#import "Signal1.h"
#import <objc/message.h>

@implementation Signal1

- (void)dispatchWithObject:(id)object
{
    [super startDispatch];
    
    ListenerNode * node = nil;
    for (node = super.head; node != nil; node = node.next) 
    {
        if (node.target)
        {
            objc_msgSend(node.target, node.listener, object);
            if (node.once)
                [super removeListener:node.target action:node.listener];
        }
        else if (node.block)
        {
            void(^block)(id) = (void(^)(id))node.block;
            block(object);
            if (node.once)
                [super removeBlockWithKey:node.key];
        }
    }
    [super endDispatch];
}

@end
