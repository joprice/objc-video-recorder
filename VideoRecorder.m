
#import "VideoRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoRecorder()

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) AVCaptureMovieFileOutput *output;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (copy) void (^onStart)();

@end

@implementation VideoRecorder

-(id)initWithFileName:(NSString *)fileName error:(NSError **)error {
  self = [super init];

  self.recording = false;
  self.fileName = fileName;

  //initialize video input
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:error];

  if (!self.input) {
    return nil;
  }

  self.output = [[AVCaptureMovieFileOutput alloc] init];

  [self.session beginConfiguration];

  self.session = [[AVCaptureSession alloc] init];
  self.session.sessionPreset = AVCaptureSessionPresetHigh;

  if([self.session canAddInput:self.input]) {
    [self.session addInput:self.input];
  }

  if([self.session canAddOutput:self.output]) {
    [self.session addOutput:self.output];
  }

  [self.session commitConfiguration];

  return self;
}

-(id)init {
  self = [super init];
  return self;
}

-(void)start:(void (^)(NSError *))onStart {
  [self.session startRunning];

  self.recording = true;

  NSURL *outputUrl = [NSURL fileURLWithPath:self.fileName];

  self.onStart = onStart;

  [self.output startRecordingToOutputFileURL:outputUrl
                      recordingDelegate:self];
}

-(void)stop {
  [self.output stopRecording];
  self.recording = false;
  //TODO: this hangs
  //[self.session removeInput:self.input];
  //[self.session removeOutput:self.output];
  //[self.session stopRunning];
}


- (void)captureOutput:(__unused AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(__unused NSURL *)fileURL
      fromConnections:(__unused NSArray *)connections {
  self.onStart(nil);
  self.onStart = nil;
}

- (void)captureOutput:(__unused AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(__unused NSURL *)outputFileURL
      fromConnections:(__unused NSArray *)connections
                error:(__unused NSError *)error  {
  if (error) {
    if (self.onStart) {
      self.onStart(error);
    } else {
      NSLog(@"Error: %@", error);
    }
  }
}

@end
