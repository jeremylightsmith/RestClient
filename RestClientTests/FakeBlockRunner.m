#import "FakeBlockRunner.h"

@implementation FakeBlockRunner

@synthesize operations;

- (id) init {
  self = [super init];
  self.operations = [[NSMutableArray alloc] init];
  return self;
}

- (void) dealloc {
  [self.operations release];
  [super dealloc];
}

- (void) runOperation:(NSOperation *)operation {
  [self.operations addObject:operation];
}

@end
