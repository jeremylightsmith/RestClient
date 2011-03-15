#import "FakeBlockRunner.h"
#import "RestClientBlockRunner.h"

DESCRIBE(RestClientBlockRunner) {
  it(@"should capture blocks as operations", ^{
    FakeBlockRunner *runner = [[FakeBlockRunner alloc] init];
    __block int result = 0;
    
    [runner run:^{ result++; }];
    
    assertThatInt(result, equalToInt(0));
    
    NSOperation *operation = [runner.operations objectAtIndex:0];
    [operation start];
    [operation waitUntilFinished];
     
    assertThatInt(result, equalToInt(1));
  });
}
DESCRIBE_END
