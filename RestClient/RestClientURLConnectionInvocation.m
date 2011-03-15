#import "RestClientURLConnectionInvocation.h"
#import "NSString+SBJSON.h"
#import "RestClient.h"

@implementation RestClientURLConnectionInvocation

- (id) initWithRequest:(NSMutableURLRequest *)aRequest
                    wait:(BOOL)aWait
                success:(void (^)(id))aOnSuccess 
                  error:(void (^)(NSError *))aOnError {
  self = [super init];
  request = [aRequest retain];
  wait = aWait;
  onSuccess = [aOnSuccess retain];
  onError = [aOnError retain];
  receivedData = [[NSMutableData alloc] initWithLength:0];
  
  statusCode = -1;
  return self;
}

- (void) dealloc {
  [request release];
  [onSuccess release];
  [onError release];
  [receivedData release];
  [super dealloc];
}

+ (NSString *) parseError:(NSString *)json {
  id hash = [json JSONValue];
  if ([hash isKindOfClass:[NSDictionary class]]) {
    return [hash objectForKey:@"error"];
  } else {
    return @"Server Error";
  }
}

- (void)startWaiting {
  [[NSNotificationCenter defaultCenter] postNotificationName:RestClientStartWaiting object:nil];
}

- (void)stopWaiting {
  [[NSNotificationCenter defaultCenter] postNotificationName:RestClientStopWaiting object:nil];
}

- (void) start {
  [self retain];
  if (wait) [self startWaiting];
  [[NSURLConnection connectionWithRequest:request delegate:self] start];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
  statusCode = [((NSHTTPURLResponse *)response) statusCode];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  onError(error);
  if (wait) [self stopWaiting];
  [self release];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
	[receivedData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
  NSString *data = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
  if (statusCode == 200) {
    onSuccess([data JSONValue]);
  } else if (statusCode != -1) {
    onError([NSError errorWithDomain:@"restclient" 
                                code:statusCode
                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [RestClientURLConnectionInvocation parseError:data], NSLocalizedDescriptionKey,
                                      nil]]);
  }
  [data release];
  if (wait) [self stopWaiting];
  [self release];
}

@end
