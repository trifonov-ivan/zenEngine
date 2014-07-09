
#import "Signal0.h"
#import <objc/message.h>

@implementation Signal0

- (void)dispatch
{
    [super startDispatch];
    
    ListenerNode * node = nil;
    for (node = super.head; node != nil; node = node.next)
    {
        if (node.target)
        {
            objc_msgSend(node.target, node.listener);
            if (node.once)
                [super removeListener:node.target action:node.listener];
        }
        else if (node.block)
        {
            void(^block)(void) = (void(^)(void))node.block;
            block();
            if (node.once)
                [super removeBlockWithKey:node.key];
        }
    }
    [super endDispatch];
}

@end
