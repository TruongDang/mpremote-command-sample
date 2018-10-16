//
//  AssetPlaybackManager.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "AssetPlaybackManager.h"

NSString *const kNextTrackNotification = @"nextTrackNotification";
NSString *const kPreviousTrackNotification = @"previousTrackNotification";
NSString *const kCurrentAssetDidChangeNotification = @"currentAssetDidChangeNotification";
NSString *const kPlayerRateDidChangeNotification = @"playerRateDidChangeNotification";

@implementation AssetPlaybackManager

-(instancetype)init {
    self = [super init];
    if (self != nil) {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentAssetDidChangeNotification object:nil];
}

- (void)play {
    if (_asset == nil) { return; }
    
    if (shouldResumePlaybackAfterInterruption == false) {
        shouldResumePlaybackAfterInterruption = true;
        return;
    }
    
    [_player play];
}

- (void)pause {
    if (_asset == nil) { return; }

    if (state == PlaybackStateInterrupted) {
        shouldResumePlaybackAfterInterruption = false;
        return;
    }
    [_player pause];
}

- (void)togglePlayPause {
    if (_asset == nil) { return; }

    if (_player.rate == 1.0) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)stop {
    if (_asset == nil) { return; }

    _asset = nil;
    _playerItem = nil;
    [_player replaceCurrentItemWithPlayerItem:nil];
}

- (void)nextTrack {
    if (_asset == nil) { return; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNextTrackNotification object:nil userInfo:@{kAssetNameKey: _asset.assetName}];
}

- (void)previousTrack {
    if (_asset == nil) { return; }
    [[NSNotificationCenter defaultCenter] postNotificationName:kPreviousTrackNotification object:nil userInfo:@{kAssetNameKey: _asset.assetName}];
}

- (void)skipForwardWithTimeInterval:(NSTimeInterval)interval {
    if (_asset == nil) { return; }
    
    CMTime currentTime = _player.currentTime;
    CMTime offset = CMTimeMakeWithSeconds(interval, 1);
    
    CMTime newTime = CMTimeAdd(currentTime, offset);
    [_player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self updatePlaybackRateMetadata];
    }];
}

- (void)skipBackwardWithTimeInterval:(NSTimeInterval)interval {
    if (_asset == nil) { return; }

    CMTime currentTime = _player.currentTime;
    CMTime offset = CMTimeMakeWithSeconds(interval, 1);

    CMTime newTime = CMTimeSubtract(currentTime, offset);
    [_player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self updatePlaybackRateMetadata];
    }];
}

- (void)seekToPosition:(NSTimeInterval)position {
    if (_asset == nil) { return; }

    CMTime newPosition = CMTimeMakeWithSeconds(position, 1);
    [_player seekToTime:newPosition toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self updatePlaybackRateMetadata];
    }];
}

- (void)beginRewind {
    if (_asset == nil) { return; }
    
    _player.rate = -2.0;
}

- (void)beginFastForward {
    if (_asset == nil) { return; }
    
    _player.rate = 2.0;
}

- (void)endRewindFastForward {
    if (_asset == nil) { return; }
    
    _player.rate = 1.0;
}

// MARK: MPNowPlayingInforCenter Management Methods
- (void)updatePlaybackRateMetadata {
    if (_player.currentItem == nil) {
        duration = 0;
        nowPlayingInfoCenter.nowPlayingInfo = nil;
        return;
    }
    
    NSMutableDictionary *nowPlayingInfo;
    if ([nowPlayingInfoCenter.nowPlayingInfo isKindOfClass:[NSDictionary class]]) {
        nowPlayingInfo = [[NSMutableDictionary alloc] initWithDictionary:nowPlayingInfoCenter.nowPlayingInfo];
    } else {
        nowPlayingInfo = [[NSMutableDictionary alloc] init];
    }
    duration = CMTimeGetSeconds(_player.currentItem.duration);
    Float64 time = CMTimeGetSeconds(_player.currentItem.currentTime);
    float rate = _player.rate;
    [nowPlayingInfo setObject:[NSNumber numberWithDouble:duration] forKey:MPMediaItemPropertyPlaybackDuration];
    [nowPlayingInfo setObject:[NSNumber numberWithDouble:time] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [nowPlayingInfo setObject:[NSNumber numberWithDouble:rate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [nowPlayingInfo setObject:[NSNumber numberWithDouble:rate] forKey:MPNowPlayingInfoPropertyDefaultPlaybackRate];
    nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo;
    
    if (_player.rate == 0.0) {
        state = PlaybackStatePaused;
        
    } else {
        state = PlaybackStatePlaying;
    }
}

// MARK: Notification Observing Methods
- (void)handleAVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    [_player replaceCurrentItemWithPlayerItem:nil];
}

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

// MARK: Key-Value Observing Method
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    NSLog(@"#keyPath(%@.%@)", NSStringFromClass([object class]), keyPath);
    if ([object isKindOfClass:[AVURLAsset class]] && (AVURLAsset *)object == _asset.urlAsset && [keyPath isEqualToString:@"isPlayable"]) {
        if (_asset.urlAsset.isPlayable) {
            [self setPlayerItem:[AVPlayerItem playerItemWithAsset:_asset.urlAsset]];
            [_player replaceCurrentItemWithPlayerItem:_playerItem];
        }
    } else if ([object isKindOfClass:[AVPlayerItem class]] && (AVPlayerItem *)object == _playerItem && [keyPath isEqualToString:@"status"]) {
        if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
            [_player play];
        }
    } else if ([object isKindOfClass:[AVPlayer class]] && (AVPlayer *)object == _player && [keyPath isEqualToString:@"currentItem"]) {
        
        // Cleanup if needed.
        if (_player.currentItem == nil) {
            _asset = nil;
            _playerItem = nil;
        }
        [self updatePlaybackRateMetadata];
    } else if ([object isKindOfClass:[AVPlayer class]] && (AVPlayer *)object == _player && [keyPath isEqualToString:@"rate"]) {
        [self updatePlaybackRateMetadata];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerRateDidChangeNotification object:nil];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
