
#import <Foundation/Foundation.h>
#import "ListenerNode.h"

@interface ListenerNodePool : NSObject

- (ListenerNode *)get;
- (void)dispose:(ListenerNode *)node;
- (void)cache:(ListenerNode *)node;
- (void)releaseCache;

@end
