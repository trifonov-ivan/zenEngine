
#import "ListenerNode.h"

@implementation ListenerNode

@synthesize previous;
@synthesize next;
@synthesize listener;
@synthesize target;
@synthesize once;

- (void) dealloc {
    self.next = nil;
    self.target = nil;
    self.block = nil;
    self.key = nil;
}

@end
