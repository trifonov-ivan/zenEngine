
#import "SignalBase.h"

@interface SignalAny : SignalBase

- (void)dispatchWithObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;

@end
