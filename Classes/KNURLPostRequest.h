//
//  KNURLPostRequest.h
//  ChunkedUpload
//
//  Created by Evan Owen on 11/29/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KNURLPostRequest : NSMutableURLRequest {
@private
    NSString *_postBoundary;
    NSMutableData *_postBody;
}

@property (retain) NSString* postBoundary;
@property (retain) NSMutableData* postBody;

- (void)addPostValue:(NSString *)value forKey:(NSString *)key;
- (void)addPostData:(NSData *)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key;
- (void)closePostBody;

@end
