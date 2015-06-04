#import <AVFoundation/AVFoundation.h>

@interface VideoRecorder: NSObject<AVCaptureFileOutputRecordingDelegate>

@property BOOL recording;

-(void)start:(void (^)(NSError *error))onStart;

-(void)stop;

-(id)initWithFileName:(NSString *)fileName error:(NSError **)error;

@end
