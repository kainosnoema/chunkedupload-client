//
//  ChunkedUploadAppDelegate.m
//  ChunkedUpload
//
//  Created by Evan Owen on 11/24/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

#import "ChunkedUploadAppDelegate.h"
#import "ChunkedUploadQueue.h"

@implementation ChunkedUploadAppDelegate

@synthesize uploadWindow;
@synthesize fileOpenPanel;
@synthesize uploadStatusLabel;
@synthesize progressIndicator;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [uploadStatusLabel setStringValue: @"Done"];
    [progressIndicator setDoubleValue:0.0];
    self.fileOpenPanel = [NSOpenPanel openPanel];
}

- (IBAction)uploadFiles:(id)sender {
    
    ChunkedUploadQueue *queue = [ChunkedUploadQueue sharedInstance];
    queue.delegate = self;
    
    void (^openHandler)(NSInteger) = ^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [queue cancelAllOperations];
            for(NSURL *url in [fileOpenPanel URLs]) {
                [queue addFile:[url path]];
            }
        }
    };
    
    [fileOpenPanel setAllowsMultipleSelection:YES];
    [fileOpenPanel beginSheetModalForWindow:uploadWindow completionHandler:openHandler];
}

- (IBAction)cancelUpload:(id)sender {
    [[ChunkedUploadQueue sharedInstance] cancelAllOperations];
}

// ChunkedUploadQueue Delegate
// ---------------------------

- (void) chunkedQueueDidUploadData:(NSInteger)bytesUploaded totalBytesUploaded:(NSInteger)totalBytesUploaded totalBytesExpectedToUpload:(NSInteger)totalBytesExpectedToUpload {
    
    int progress = ((float)totalBytesUploaded / (float)totalBytesExpectedToUpload) * 100;
    double uploaded = (float)totalBytesUploaded / (1024*1024);
    double total = (float)totalBytesExpectedToUpload / (1024*1024);
    
    [uploadStatusLabel setStringValue: [NSString stringWithFormat: @"Uploaded %1.1f MB of %1.1f MB (%i%%)", uploaded, total, progress]];
    [progressIndicator setDoubleValue:(double)progress];
}

- (void) chunkedQueueDidFinishUploading {
    [uploadStatusLabel setStringValue: @"Done"];
    [progressIndicator setDoubleValue:0.0];
}

@end
