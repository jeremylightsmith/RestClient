RestClient
==========

This is meant to be a simple way of calling restful json based webservices.  We prefer keeping things simple.  So use synchronous calls when you can, and when you can't, use blocks so you keep all your logic in one place.

This was developed on Maptini (http://maptini.com/) so thanks them for making this available.

Usage
-----

Simple synchronous usage:

    RestClient *client = [[RestClient alloc] init];
    NSDictionary *response = [[client get:"http://maptini.com/users.json"] JSONValue];
    [client release]

Synchronous usage with prefix & headers:

    RestClient *client = [[RestClient alloc] initWithPrefix:@"http://maptini.com/api" 
                                                 andHeaders:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              userAPIToken, @"X-MaptiniToken",
                                                              @"4.0", @"X-MaptiniVersion", nil]];
    NSDictionary *response = [[client post:"/users.json" withBody:body] JSONValue];
    [client release]

Synchronous usage with error handling:

    RestClient *client = [[RestClient alloc] init];
    @try {
      return [[client get:"http://maptini.com/users"] JSONValue];
    }
    @catch (NSException * e) {
      // handle the error
      return ...
    }
    @finally {
      [client release];
    }

Asynchronous usage:

    RestClient *client = [[RestClient alloc] init];
    [client get:@"/account.json"
           wait:true
        success:[[^(id json) { 
          User *user = [[User alloc] initWithDictionary:[NSDictionary dictionaryWithDictionary:[json objectForKey:@"user"]]];
          [user store];
          [[NSNotificationCenter defaultCenter] postNotificationName:CMDidLogin object:nil];
          [user release];
        } copy] autorelease]
                   error:^(NSError *error) { 
                     [error showWithTitle:NSLocalizedString(@"ErrorConnectionTitle", @"")];
                   }];
    [client release];


Contact
-------

Jeremy Lightsmith
jeremy.lightsmith@gmail.com