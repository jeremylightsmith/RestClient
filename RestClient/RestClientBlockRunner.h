@interface RestClientBlockRunner : NSObject {

}

- (void)run:(void (^)(void))block;
- (void)runOperation:(NSOperation *)operation;

@end
