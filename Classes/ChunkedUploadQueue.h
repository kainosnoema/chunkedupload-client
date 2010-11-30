//
//  ChunkedUpload.h
//  ChunkedUpload
//
//  Created by Evan Owen on 11/24/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChunkedUploadOperation.h"
#import "ChunkedUploadConstants.h"

@protocol ChunkedUploadQueueDelegate
- (void) chunkedQueueDidUploadData:(NSInteger)bytesUploaded totalBytesUploaded:(NSInteger)totalBytesUploaded totalBytesExpectedToUpload:(NSInteger)totalBytesExpectedToUpload;
- (void) chunkedQueueDidFinishUploading;
@end

@interface ChunkedUploadQueue : NSOperationQueue <ChunkedUploadOperationDelegate> {
@private
    id <ChunkedUploadQueueDelegate> _delegate;
    NSInteger _totalBytesUploaded;
    NSInteger _totalBytesExpectedToUpload;
}

@property (retain, nonatomic) id <ChunkedUploadQueueDelegate> delegate;
@property () NSInteger totalBytesUploaded;
@property () NSInteger totalBytesExpectedToUpload;

+ (ChunkedUploadQueue *)sharedInstance;
- (void) addFile:(NSString *)path;

@end
