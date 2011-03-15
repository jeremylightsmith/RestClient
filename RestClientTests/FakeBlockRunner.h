#include "RestClientBlockRunner.h"

@interface FakeBlockRunner : RestClientBlockRunner {
  NSMutableArray *operations;
}

@property (nonatomic, retain) NSMutableArray* operations;

@end
