#import "VideoRecorder.h"

#import <Foundation/Foundation.h>

#if ! __has_feature(objc_arc)
#error "ARC is off"
#endif

static VideoRecorder *recorder;

void signalHandler(int sig) {
  if ([recorder recording]) {
    [recorder stop];
  }
  exit(sig);
}

int main(int argc __attribute__((unused)), const char *argv[] __attribute__((unused))) {
  float recordSeconds = 5.0f;
  NSString *fileName = @"/tmp/vid.mp4";

  NSError *error = nil;
  VideoRecorder *recorder = [[VideoRecorder alloc] initWithFileName:fileName error:&error];

  signal(SIGINT, signalHandler);

  if (!error) {
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];

    dispatch_queue_t imageQueue = dispatch_queue_create("recorder",NULL);

    dispatch_async(imageQueue, ^{
      [recorder start:^(NSError *error) {
        dispatch_queue_t waitQueue = dispatch_queue_create("waiting",NULL);
        dispatch_async(waitQueue, ^{
          [lock lock];
          if (error) {
            NSLog(@"Error: %@", error);
          } else {
            [NSThread sleepForTimeInterval:recordSeconds];
            [recorder stop];
          }

          [lock unlockWithCondition: 1];
        });
      }];
    });

    if (![lock tryLockWhenCondition: 1]) {
      [lock lockWhenCondition: 1];
    }
    // lock will throw error if not unlocked before being deallocated
    [lock unlock];
  } else {
    NSLog(@"%@", error);
  }

}
