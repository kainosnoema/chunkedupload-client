//
//  ChunkedUploader.h
//  ChunkedUpload
//
//  Created by Evan Owen on 11/24/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChunkedUploadConstants.h"

@protocol ChunkedUploadOperationDelegate
- (void) operation:(ChunkedUploadOperation *)operation didUploadData:(NSInteger)bytesUploaded totalBytesUploaded:(NSInteger)totalBytesUploaded totalBytesExpectedToUpload:(NSInteger)totalBytesExpectedToUpload;
- (void) operation:(ChunkedUploadOperation *)operation didFailWithError:(NSError *)error;
- (void) operationDidFinishUploading:(ChunkedUploadOperation *)operation;
@end

@interface ChunkedUploadOperation : NSOperation {

@private
    id <ChunkedUploadOperationDelegate> _delegate;

    NSURLConnection *_connection;

    NSString *_filePath;
    NSString *_fileUUID;
    unsigned long long _fileSize;
    int _chunkIndex;
    
    NSHTTPURLResponse *_response;
    NSMutableData *_responseData;

    BOOL _isFinished;
    BOOL _isExecuting;
    BOOL _isCanceled;
}

@property (retain, nonatomic) id <ChunkedUploadOperationDelegate> delegate;

@property () BOOL isFinished;
@property () BOOL isExecuting;
@property () BOOL isCanceled;

@property (retain) NSString* filePath;
@property (retain) NSString* fileUUID;
@property () unsigned long long fileSize;
@property () int chunkIndex;


+ (id)operationWithFile:(NSString *)path fileUUID:(NSString *)fileUUID fileSize:(unsigned long long)fileSize chunkIndex:(int)chunkIndex delegate:(id<ChunkedUploadOperationDelegate>)delegate;
- (id)getResponseData;

@end
