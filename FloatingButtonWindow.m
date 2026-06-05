/*
    Copyright (C) 2025  Serge Alagon
    GPL v3 License

    Logic-only manager (no UI components)
*/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <notify.h>

static NSString * const kImmortalizedKey = @"immortalized";

@interface ImmortalizerManager : NSObject

@property (nonatomic, assign) BOOL immortalized;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

+ (instancetype)shared;

- (void)toggleImmortalized;
- (void)setImmortalized:(BOOL)state;

@end

@implementation ImmortalizerManager

+ (instancetype)shared {
    static ImmortalizerManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ImmortalizerManager alloc] init];
        shared.immortalized = [[NSUserDefaults standardUserDefaults] boolForKey:kImmortalizedKey];
    });
    return shared;
}

#pragma mark - State control

- (void)toggleImmortalized {
    [self setImmortalized:!self.immortalized];
}

- (void)setImmortalized:(BOOL)state {
    _immortalized = state;

    [[NSUserDefaults standardUserDefaults] setBool:state forKey:kImmortalizedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    notify_post("com.sergy.immortalizerjailed.updateprefs");

    if (state) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}

#pragma mark - Timer system

- (void)startTimer {
    [self.timer invalidate];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerFired)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self stopPlayingSilentAudio];
}

- (void)timerFired {
    [self startPlayingSilentAudio];
}

#pragma mark - Silent audio loop

- (void)startPlayingSilentAudio {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionMixWithOthers
                   error:nil];

    [session setActive:YES error:nil];

    NSData *audioData = [[NSData alloc] initWithBase64EncodedString:kBase64Audio
                                                             options:NSDataBase64DecodingIgnoreUnknownCharacters];

    if (!audioData) return;

    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    self.audioPlayer.volume = 0.0;
    self.audioPlayer.numberOfLoops = -1;

    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)stopPlayingSilentAudio {
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

@end
