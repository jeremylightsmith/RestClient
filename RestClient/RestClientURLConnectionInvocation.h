
@interface RestClientURLConnectionInvocation : NSObject {
  NSMutableURLRequest *request;
  BOOL wait;
  void (^onSuccess)(id);
  void (^onError)(NSError *);
  int statusCode;
  NSMutableData *receivedData;
}

- (id)initWithRequest:(NSMutableURLRequest *)request 
                   wait:(BOOL)wait 
                success:(void (^)(id))onSuccess 
                  error:(void (^)(NSError *))onError;
- (void)start;

+ (NSString *)parseError:(NSString *)error;

@end
