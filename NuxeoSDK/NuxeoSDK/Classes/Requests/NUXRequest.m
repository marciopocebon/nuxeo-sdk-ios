//
//  NUXRequest.m
//  NuxeoSDK
//
//  Created by Arnaud Kervern on 14/11/13.
//  Copyright (c) 2013 Nuxeo. All rights reserved.
//

#import "NUXRequest.h"

@interface NUXRequest ()
@property NSURL *url;
@property NUXSession *session;
@property NSMutableDictionary *mutableHeaders;
@end

@implementation NUXRequest

NUXResponseBlock _completion;
NUXResponseBlock _failure;

NSData *_responseData;

-(id)init {
    self = [super init];
    if (self) {
        self.method = @"GET";
        self.contentType = @"application/json";
        
        _adaptors = [NSArray new];
        _categories = [NSArray new];
        _schemas = [NSArray new];
        _postData = [NSMutableData new];
        _mutableHeaders = [NSMutableDictionary new];
    }
    return self;
}

- (id)initWithSession:(NUXSession *)session {
    self = [self init];
    if (self) {
        self.session = session;
        self.url = [session.url copy];
    }
    return self;
}

- (void)dealloc {
    _downloadDestinationPath = nil;
    _adaptors = Nil;
    _categories = Nil;
    _schemas = Nil;
    _responseMessage = Nil;
    _responseData = Nil;
    _contentType = Nil;
    self.url = Nil;
    self.method = Nil;
    self.repository = Nil;
    self.postData = Nil;
}

- (NUXRequest *)addURLSegment:(NSString *)aSegment {
    self.url = [self.url URLByAppendingPathComponent:aSegment];
    return self;
}

- (NUXRequest *)addAdaptor:(NSString *)adaptor {
    [self addURLSegment:[NSString stringWithFormat:@"@%@", adaptor]];
    _adaptors = [_adaptors arrayByAddingObject:adaptor];
    return self;
}

- (NUXRequest *)addAdaptor:(NSString *)adaptor withValue:(NSString *)value {
    [self addAdaptor:adaptor];
    [self addURLSegment:value];
    return self;
}

- (NUXRequest *)addCategory:(NSString *)category {
    _categories = [_categories arrayByAddingObject:category];
    return self;
}

- (NUXRequest *)addCategories:(NSArray *)categories {
    _categories = [_categories arrayByAddingObjectsFromArray:categories];
    return self;
}

- (NUXRequest *)addSchema:(NSString *)schema {
    _schemas = [_schemas arrayByAddingObject:schema];
    return self;
}

- (NUXRequest *)addSchemas:(NSArray *)schemas {
    _schemas = [_schemas arrayByAddingObjectsFromArray:schemas];
    return self;
}


- (NUXRequest *)addHeaderWithKey:(NSString *)key value:(NSString *)value {
    [self.mutableHeaders setObject:value forKey:key];
    return self;
}

- (NSURL *)URL {
    return self.url;
}

- (NSDictionary *)headers {
    return [NSDictionary dictionaryWithDictionary:self.mutableHeaders];
}

- (void)setCompletionBlock:(NUXResponseBlock)aCompletionBlock {
    _completion = aCompletionBlock;
}

- (void)setFailureBlock:(NUXResponseBlock)aFailureBlock {
    _failure = aFailureBlock;
}

- (void)start {
    [self.session startRequest:self withCompletionBlock:^{
        if (_completion != nil) {
            _completion(self);
        }
    }             failureBlock:^{
        if (_failure != nil) {
            _failure(self);
        }
    }];
}

- (void)startSynchronous {
    [self.session startRequestSynchronous:self withCompletionBlock:^{
        if (_completion != nil) {
            _completion(self);
        }
    }                        failureBlock:^{
        if (_failure != nil) {
            _failure(self);
        }
    }];
}

- (void)startWithCompletionBlock:(NUXResponseBlock)completion FailureBlock:(NUXResponseBlock)failure {
    [self.session startRequest:self withCompletionBlock:^{
        completion(self);
    }             failureBlock:^{
        failure(self);
    }];
}


- (void)setResponseData:(NSData *)data WithEncoding:(NSStringEncoding)encoding StatusCode:(int)statusCode message:(NSString *)message {
    _responseData = data;
    _responseStatusCode = statusCode;
    _responseMessage = message;
}

- (NSData *)responseData {
    return _responseData;
}

- (NSString *)responseString {
    return [[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding];
}

- (id)responseJSONWithError:(NSError **)error {
    id res = [NSJSONSerialization JSONObjectWithData:[self responseData] options:NSJSONReadingMutableContainers error:error];

    return res;
}

@end