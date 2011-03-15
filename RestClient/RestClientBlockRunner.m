#import "RestClientBlockRunner.h"

@implementation RestClientBlockRunner

- (void) run:(void (^)(void))block {
  [self runOperation:[NSBlockOperation blockOperationWithBlock:block]];
}

- (void) runOperation:(NSOperation *)operation {
  [operation start];
}

@end
