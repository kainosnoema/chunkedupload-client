## DESCRIPTION

ChunkUpload is an experimental Objective-C project demonstrating a
method to upload very large files by splitting them into small 1-5 MB chunks
and distributing them across multiple concurrent HTTP POST requests. Using
this method, pausing and resuming uploads should be quite simple and will be
implemented soon.

For the companion node.js server project, see:
http://github.com/kainosnoema/chunkedupload-server

## Project Goals:

1. Upload very large files
1. Show real-time upload feedback
1. Pause and resume uploads
1. Use minimal memory footprint