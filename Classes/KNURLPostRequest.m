//
//  KNURLPostRequest.m
//  ChunkedUpload
//
//  Created by Evan Owen on 11/29/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

#import "KNURLPostRequest.h"

@interface KNURLPostRequest (Private)

- (void)openPostBody;
- (void)addBoundary;

@end

@implementation KNURLPostRequest

@synthesize postBoundary = _postBoundary;
@synthesize postBody = _postBody;

- (void)dealloc {
    self.postBoundary = nil;
    self.postBody = nil;
    
    [super dealloc];
}

- (void)openPostBody {
    self.postBoundary = @"---##---KNURLPostRequestMultipartBoundary---##---";
    self.postBody = [NSMutableData data];
    
    [self setHTTPMethod:@"POST"];
    [self setValue:[NSString stringWithFormat:@"multipart/form-data, boundary=%@", self.postBoundary] forHTTPHeaderField:@"Content-type"];
}

- (void)addBoundary {
    if(_postBody == nil) {
        [self openPostBody];
    }
    
    if([_postBody length] == 0) {
        [_postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", self.postBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        [_postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", self.postBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)addPostValue:(NSString *)value forKey:(NSString *)key {
    [self addBoundary];
    [_postBody appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [_postBody appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addPostData:(NSData *)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key {
    [self addBoundary];
    [_postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [_postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
    [_postBody appendData:data];
}

- (void)closePostBody {
    [_postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", self.postBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setValue:[NSString stringWithFormat:@"%d", [_postBody length]] forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:self.postBody];
}

@end
