//
//  ImmortalizerManager.h
//  Logic-only controller (no UI)
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ImmortalizerManager : NSObject

@property (nonatomic, assign) BOOL immortalized;
@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, strong, readonly) AVAudioPlayer *audioPlayer;

+ (instancetype)shared;

// Main controls
- (void)toggleImmortalized;
- (void)setImmortalized:(BOOL)state;

@end
