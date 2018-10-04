//
//  AssetPlaybackManager.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "AssetPlaybackManager.h"

@implementation AssetPlaybackManager

-(instancetype)init {
    self = [super init];
    if (self != nil) {
        nextTrackNotification = [NSNotification notificationWithName:@"nextTrackNotification" object:nil];
        previousTrackNotification = [NSNotification notificationWithName:@"previousTrackNotification" object:nil];
        currentAssetDidChangeNotification = [NSNotification notificationWithName:@"currentAssetDidChangeNotification" object:nil];
        playerRateDidChangeNotification = [NSNotification notificationWithName:@"playerRateDidChangeNotification" object:nil];
        _player = [AVPlayer new];
        nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
        _percentProgress = 0;
        duration = 0;
        _playbackPosition = 0;
        shouldResumePlaybackAfterInterruption = YES;
        // Add the notification observer needed to respond to audio interruptions.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        // Add the Key-Value Observers needed to keep internal state of `AssetPlaybackManager` and `MPNowPlayingInfoCenter` in sync.
        [_player addObserver:self forKeyPath:@"currentItem" options:(NSKeyValueObservingOptionInitial + NSKeyValueObservingOptionNew) context:nil];
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        
        // Add a periodic time observer to keep `percentProgress` and `playbackPosition` up to date.
        __weak typeof(self) weakSelf = self;
        timeObserverToken = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            Float64 timeElapsed = CMTimeGetSeconds(time);
            CMTime duration = weakSelf.player.currentItem.duration;
            Float64 durationInSecods = CMTimeGetSeconds(duration);
            weakSelf.playbackPosition = timeElapsed;
            weakSelf.percentProgress = timeElapsed / durationInSecods;
        }];

    }
    return self;
}

-(void)dealloc {
    [_player removeObserver:self forKeyPath:@"currentItem" context:nil];
    [_player removeObserver:self forKeyPath:@"rate" context:nil];
    if (timeObserverToken != nil) {
        [_player removeTimeObserver:timeObserverToken];
        timeObserverToken = nil;
    }
    
}

-(void)setPlayerItem:(AVPlayerItem *)playerItem {
    [_playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    _playerItem = playerItem;
    [_playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionInitial + NSKeyValueObservingOptionNew) context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

-(void)setAsset:(Asset *)asset {
//    willSet
    if (_asset != nil) {
        [_asset.urlAsset removeObserver:self forKeyPath:@"isPlayable" context:nil];
    }
    _asset = asset;
//    didSet
    if (_asset != nil) {
        [_asset.urlAsset addObserver:self forKeyPath:@"isPlayable" options:(NSKeyValueObservingOptionInitial + NSKeyValueObservingOptionNew) context:nil];
    } else {
        // Unload currentItem so that the state is updated globally.
        [_player replaceCurrentItemWithPlayerItem:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentAssetDidChangeNotification" object:nil];
}

- (void)play {}

- (void)handleAudioSessionInterruption:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionInterruptionType interruptionType = (AVAudioSessionInterruptionType)[userInfo objectForKey:AVAudioSessionInterruptionTypeKey];
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan: {
            state = PlaybackStateInterrupted;
            break;
        }
            
        case AVAudioSessionInterruptionTypeEnded: {
            @try {
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            } @catch (NSException *exception) {
                NSLog(@"An Error occured activating the audio session while resuming from interruption: %@", [exception description]);
            }
            
            if (shouldResumePlaybackAfterInterruption == NO) {
                shouldResumePlaybackAfterInterruption = YES;
                return;
            }
            
            if([[notification.userInfo valueForKey:AVAudioSessionInterruptionOptionKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionOptionShouldResume]]){
                [self play];
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)handleAVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    
}

@end
