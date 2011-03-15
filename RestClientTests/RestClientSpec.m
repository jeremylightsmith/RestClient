#import "RestClient.h"
#import "FakeClient.h"
#import "FakeNotificationCenter.h"
#import "SBJSON.h"
#import "RestClientURLConnectionInvocation.h"

DESCRIBE(RestClient) {
  describe(@"integration tests", ^{
    __block RestClient *client;

    beforeEach(^{
      client = [[RestClient alloc] init];
    });
    
    it(@"should actually hit the server", ^{
      SBJSON *json = [[SBJSON alloc] init];
      @try {
        client.userAPIToken = @"1IMMXTkteQ6t9pbDEwRm";
        
        //assertThat([client get:@"/api/sessions/create?/maps.json"], is(@"OK"));
        
        assertThat([client post:@"/maps.json" 
                       withBody:@"{map:{id:\"test\",name:\"foo\",root_node:{id:\"testroot\",name:\"foo\"}}}"], 
                   is(@"OK"));
        assertThat([client get:@"/maps/test/version.json"], 
                   is(@"1"));
        
        assertThat([client post:@"/maps/test/commands.json"
                       withBody:@"{command:{command_name:\"UpdateNode\",node_id:\"testroot\",field:\"name\",value:\"bob\"}}"], 
                   is(@"{\"version\":2}"));
        assertThat([client get:@"/maps/test/version.json"], 
                   is(@"2"));
        
        assertThat([client post:@"/maps/test/commands.json"
                       withBody:@"{command:{command_name:\"UpdateNode\",node_id:\"testroot\",field:\"name\",value:\"roger\"}}"],
                   is(@"{\"version\":3}"));
        assertThat([client get:@"/maps/test/version.json"], 
                   is(@"3"));
        
        NSString *expected = @"[{\"command_name\":\"UpdateNode\",\"node_id\":\"testroot\",\"field\":\"name\",\"value\":\"roger\",\"version\":3}]";
        NSString *actual = [client get:@"/maps/test/commands.json?since=2"];
        assertThat([json objectWithString:expected], is([json objectWithString:actual]));
      }
      @finally {
        [client delete:@"/maps/test.json"];
      }
    });
  });
  
  describe(@"asynchronous calls", ^{
    __block FakeClient *client;
    __block NSString *result;

    beforeEach(^{
      result = nil;
      client = [[FakeClient alloc] init];
    });
    
    it(@"should do a get", ^{
      [client stub:@"GET" forPath:@"/maps.json" andReturn:@"hello"];
      
      [client get:@"/maps.json"
             wait:false
          success:^(id json) { result = [[NSString stringWithFormat:@"SUCCESS:%@", json, nil] retain]; }
            error:^(NSError *error) { fail(@"what?"); }];
      
      assertThat(result, is(@"SUCCESS:hello"));
      [result release];
    });
    
    it(@"should handle an error", ^{
      [client stub:@"GET" forPath:@"/maps.json" andThrow:303 withMessage:@"WTF, mate"];
      
      [client get:@"/maps.json"
             wait:false
          success:^(id json) { fail(@"what?"); }
            error:^(NSError *error) { 
              result = [[NSString stringWithFormat:@"ERROR:%i:%@", 
                          [error code], 
                          [[error userInfo] objectForKey:NSLocalizedDescriptionKey]] retain]; 
            }];
      
      assertThat(result, is(@"ERROR:303:WTF, mate"));
      [result release];
    });
    
    it(@"should know how to parse an error", ^{
      assertThat([RestClientURLConnectionInvocation parseError:@"{\"error\":\"WTF, mate\"}"], is(@"WTF, mate"));
      assertThat([RestClientURLConnectionInvocation parseError:@"crap"], is(@"Server Error"));
    });
    
    // post
    // put
    // delete
  });
}
DESCRIBE_END
