//
//  ChunkedUpload.m
//  ChunkedUpload
//
//  Created by Evan Owen on 11/24/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

#import "ChunkedUploadQueue.h"
#import "ChunkedUploadOperation.h"
#import "KNURLPostRequest.h"

static ChunkedUploadQueue *sharedInstance = nil;

@implementation ChunkedUploadQueue

@synthesize delegate = _delegate;
@synthesize totalBytesUploaded = _totalBytesUploaded;
@synthesize totalBytesExpectedToUpload = _totalBytesExpectedToUpload;

- (void) addFile:(NSString *)path {
    
    NSString *fileUUID = [[[NSProcessInfo processInfo] globallyUniqueString] substringWithRange:NSMakeRange(0,6)];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	unsigned long long fileSize = [fileAttributes fileSize];
    NSInteger chunkCount = ceil((float) fileSize / ChunkedUploadChunkSize);
    for(int i=0; i<chunkCount; i++) {
        [self addOperation:[ChunkedUploadOperation operationWithFile:path fileUUID:fileUUID fileSize:fileSize chunkIndex:i delegate:self]];
    }
    self.totalBytesExpectedToUpload += fileSize;
}

//- (void) sendFileStatusRequest:(NSString *)path {
//    KNURLPostRequest *req = [KNURLPostRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000/status"]];
//    [req addPostValue:[path lastPathComponent] forKey:@"fileName"];
//    [req closePostBody];
//}

- (void) cancelAllOperations {
    [super cancelAllOperations];
    self.totalBytesUploaded = 0;
    self.totalBytesExpectedToUpload = 0;
    [_delegate chunkedQueueDidFinishUploading];
}

// ChunkedUploadOperation Delegate
// -------------------------------
- (void) operation:(ChunkedUploadOperation *)operation didUploadData:(NSInteger)bytesUploaded totalBytesUploaded:(NSInteger)totalBytesUploaded totalBytesExpectedToUpload:(NSInteger)totalBytesExpectedToUpload {
    self.totalBytesUploaded += bytesUploaded;
    [_delegate chunkedQueueDidUploadData:bytesUploaded totalBytesUploaded:self.totalBytesUploaded totalBytesExpectedToUpload:self.totalBytesExpectedToUpload];
}

- (void) operationDidFinishUploading:(ChunkedUploadOperation *)operation {
    if([self operationCount] == 0) {
        [_delegate chunkedQueueDidFinishUploading];
    }
}

- (void) operation:(ChunkedUploadOperation *)operation didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

// SINGLETON METHODS
// -----------------
- (id)init {
    self = [super init];
    self.maxConcurrentOperationCount = ChunkedUploadConcurrentOperations;
    
    return self;
}

+ (ChunkedUploadQueue *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[ChunkedUploadQueue alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
