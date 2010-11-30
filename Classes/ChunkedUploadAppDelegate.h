//
//  ChunkedUploadAppDelegate.h
//  ChunkedUpload
//
//  Created by Evan Owen on 11/24/10.
//  Copyright 2010 kainosnoema. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "ChunkedUploadQueue.h"

@interface ChunkedUploadAppDelegate : NSObject <NSApplicationDelegate, ChunkedUploadQueueDelegate> {
    NSWindow *uploadWindow;
    NSOpenPanel *fileOpenPanel;
    NSTextField *uploadStatusLabel;
    NSProgressIndicator *progressIndicator;
}

@property (assign) IBOutlet NSWindow *uploadWindow;
@property (retain) NSOpenPanel *fileOpenPanel;
@property (retain) IBOutlet NSTextField *uploadStatusLabel;
@property (retain) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)uploadFiles:(id)sender;
- (IBAction)cancelUpload:(id)sender;

@end
