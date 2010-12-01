//
//  ChunkedUploadConstants.h
//  ChunkedUpload
//
//  Created by Evan Owen on 11/24/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

@class ChunkedUploadOperation;

static NSInteger const ChunkedUploadChunkSize = 5 * (1024 * 1024);
static NSInteger const ChunkedUploadConcurrentOperations = 5;