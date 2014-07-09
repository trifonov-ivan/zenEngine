
#import <Foundation/Foundation.h>

@interface ListenerNode : NSObject

@property (nonatomic, unsafe_unretained) ListenerNode * previous;
@property (nonatomic, strong) ListenerNode * next;
@property (nonatomic, assign) SEL listener;
@property (nonatomic, assign) id target;
@property (nonatomic, copy) id block;
@property (nonatomic, assign) BOOL once;
@property (nonatomic, copy) NSString *key;

@end
