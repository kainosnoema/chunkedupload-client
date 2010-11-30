//
//  ChunkedUploader.m
//  ChunkedUpload
//
//  Created by Evan Owen on 11/24/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

#import "ChunkedUploadOperation.h"
#import "ChunkedUploadConstants.h"
#import "KNURLPostRequest.h"

#define KVO_SET(_key_, _value_) [self willChangeValueForKey:@#_key_]; \
self._key_ = (_value_); \
[self didChangeValueForKey:@#_key_];

@interface ChunkedUploadOperation (Private)

- (id)initWithFile:(NSString *)path fileUUID:(NSString *)fileUUID fileSize:(unsigned long long)fileSize chunkIndex:(int)chunkIndex delegate:(id<ChunkedUploadOperationDelegate>)delegate;
- (NSURLRequest *)readChunkAndBuildRequest;

@end

@implementation ChunkedUploadOperation

@synthesize delegate = _delegate;

@synthesize isFinished = _isFinished;
@synthesize isExecuting = _isExecuting;
@synthesize isCanceled = _isCanceled;

@synthesize filePath = _filePath;
@synthesize fileUUID = _fileUUID;
@synthesize fileSize = _fileSize;
@synthesize chunkIndex = _chunkIndex;

- (void)dealloc {
    [_connection release];
    [_response release];
    [_responseData release];

    self.filePath = nil;
    self.fileUUID = nil;
    self.fileSize = 0;
    self.chunkIndex = 0;
    
    [super dealloc];
}

+ (id)operationWithFile:(NSString *)path fileUUID:(NSString *)fileUUID fileSize:(unsigned long long)fileSize chunkIndex:(int)chunkIndex delegate:(id<ChunkedUploadOperationDelegate>)delegate {
    return [[self alloc] initWithFile:path fileUUID:fileUUID fileSize:fileSize chunkIndex:chunkIndex delegate:delegate];
}

- (id)initWithFile:(NSString *)path fileUUID:(NSString *)fileUUID fileSize:(unsigned long long)fileSize chunkIndex:(int)chunkIndex delegate:(id<ChunkedUploadOperationDelegate>)delegate {
    if((self = [super init])) {
        self.delegate = delegate;
        self.filePath = path;
        self.fileUUID = fileUUID;
        self.fileSize = fileSize;
        self.chunkIndex = chunkIndex;
        
        _responseData = [[NSMutableData alloc] init];
        
        _isFinished = NO;
        _isCanceled = NO;
        _isExecuting = NO;
    }

    return self;
}

- (void)start {
    if (self.isCanceled || self.isFinished) return;
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    KVO_SET(isExecuting, YES);
    
    _connection = [[NSURLConnection alloc] initWithRequest:[self readChunkAndBuildRequest] delegate:self];
    [_connection start];
}

- (void)cancel {
    @synchronized(self) {
        if (self.isCanceled) return; // Already canceled
        
        KVO_SET(isCanceled, YES);
        KVO_SET(isFinished, YES);
        KVO_SET(isExecuting, NO);
        
        [_connection cancel];
    }
    
    [self autorelease];
}

- (void)stop {
    @synchronized(self) {
        if (!self.isExecuting) return; // Already stopped
        
        KVO_SET(isFinished, YES);
        KVO_SET(isExecuting, NO);
        
        [_connection cancel];
    }
    
    [self autorelease];
}

- (id)getResponseData {
    return [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] autorelease];
}

- (NSURLRequest *)readChunkAndBuildRequest {
    
    //open and read proper portion of file
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.filePath];
    [handle seekToFileOffset:(unsigned long long)self.chunkIndex * ChunkedUploadChunkSize];
    NSData *fileData = [handle readDataOfLength:ChunkedUploadChunkSize];
    if(fileData == nil) {
        [self cancel];
        //[_delegate operation:self didFailWithError:[NSError ini]];
    }
    
    NSString *fileName = [self.filePath lastPathComponent];
    NSString *newFileName = [NSString stringWithFormat: @"%@_%@.%@", [fileName stringByDeletingPathExtension], self.fileUUID, [fileName pathExtension]];
    
    KNURLPostRequest *req = [KNURLPostRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/upload"]];
    [req addPostValue:[NSString stringWithFormat: @"%llu", self.fileSize] forKey:@"fileSize"];
    [req addPostValue:[NSString stringWithFormat: @"%i", ChunkedUploadChunkSize] forKey:@"chunkSize"];
    [req addPostValue:[NSString stringWithFormat: @"%i", self.chunkIndex] forKey:@"chunkIndex"];
    [req addPostData:fileData withFileName:newFileName andContentType:@"application/octet-stream" forKey:newFileName];    
    [req closePostBody];
    
    return req;
}

// NSURLConnection Delegate
// ------------------------
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    [_delegate operation:self didUploadData:bytesWritten totalBytesUploaded:totalBytesWritten totalBytesExpectedToUpload:totalBytesExpectedToWrite];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (response != _response) {
        [_response release];
        _response = [response retain];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    // Not implemented yet.
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self stop];
    [_delegate operation:self didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self stop];
    [_delegate operationDidFinishUploading:self];
}

@end
