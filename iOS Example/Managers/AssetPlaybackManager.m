//
//  AssetPlaybackManager.m
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "AssetPlaybackManager.h"

@interface AssetPlaybackManager ()

// MARK: Private properties
/// The instance of `MPNowPlayingInfoCenter` that is used for updating metadata for the currently playing `Asset`.
@property (nonatomic, strong) MPNowPlayingInfoCenter *nowPlayingInfoCenter;

/// A token obtained from calling `player`'s `addPeriodicTimeObserverForInterval(_:queue:usingBlock:)` method.
@property (nonatomic, strong) id timeObserverToken;

/// The progress in percent for the playback of `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
@property (nonatomic, assign) float percentProgress;

/// The total duration in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
@property (nonatomic, assign) Float32 duration;

/// The total duration in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
@property (nonatomic, assign) Float32 playbackPosition;

/// The state that the internal `AVPlayer` is in.
@property (nonatomic, assign) AssetPlaybackManagerState state;

/// A Bool for tracking if playback should be resumed after an interruption.  See README.md for more information.
@property (nonatomic, assign) BOOL shouldResumePlaybackAfterInterruption;

/// The AVPlayerItem associated with AssetPlaybackManager.asset.urlAsset
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end


@implementation AssetPlaybackManager

//@dynamic percentProgress, duration, playbackPosition;

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.player = [[AVPlayer alloc] init];
        self.nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
        self.percentProgress = 0;
        self.duration = 0;
        self.playbackPosition = 0;
        self.shouldResumePlaybackAfterInterruption = YES;
        
        // Add the notification observer needed to respond to audio interruptions.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        // Add the Key-Value Observers needed to keep internal state of `AssetPlaybackManager` and `MPNowPlayingInfoCenter` in sync.
        [self.player addObserver:self forKeyPath:@"currentItem" options:(NSKeyValueObservingOptionInitial + NSKeyValueObservingOptionNew)context:nil];
        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        
        // Add a periodic time observer to keep `percentProgress` and `playbackPosition` up to date.
        __weak typeof(self) weakSelf = self;
        self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            Float64 timeElapsed = CMTimeGetSeconds(time);
            weakSelf.playbackPosition = timeElapsed;
            
            AVPlayerItem *currentItem = weakSelf.player.currentItem;
            if (currentItem == nil) { return; }
            CMTime duration = weakSelf.player.currentItem.duration;
            Float64 durationInSecods = CMTimeGetSeconds(duration);
            
            weakSelf.percentProgress = timeElapsed / durationInSecods;
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:_playerItem];
    [self.player removeObserver:self forKeyPath:@"currentItem"];
    [self.player removeObserver:self forKeyPath:@"rate"];
}

- (void)play {
    if (self.asset == nil) { return; }
    
    if (self.shouldResumePlaybackAfterInterruption == false) {
        self.shouldResumePlaybackAfterInterruption = true;
        return;
    }
    [self.player play];
}

- (void)pause {
    if (self.asset == nil) { return; }
    
    if (self.state == PlaybackStateInterrupted) {
        self.shouldResumePlaybackAfterInterruption = false;
        return;
    }
    [self.player pause];
}

- (void)togglePlayPause {
    if (self.asset == nil) { return; }
    
    if (self.player.rate == 1.0) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)stop {
    if (self.asset == nil) { return; }
    
    self.asset = nil;
    self.playerItem = nil;
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

- (void)nextTrack {
    if (self.asset == nil) { return; }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AssetPlaybackManager.nextTrackNotification object:@{Asset.nameKey: self.asset.assetName}];
}

- (void)previousTrack {
    if (self.asset == nil) { return; }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AssetPlaybackManager.previousTrackNotification object:@{Asset.nameKey: self.asset.assetName}];
}

- (void)skipForwardWithTimeInterval:(NSTimeInterval)interval {
    if (self.asset == nil) { return; }
    
    CMTime currentTime = self.player.currentTime;
    CMTime offset = CMTimeMakeWithSeconds(interval, 1);
    
    CMTime newTime = CMTimeAdd(currentTime, offset);
    [self.player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self updatePlaybackRateMetadata];
    }];
}

- (void)skipBackwardWithTimeInterval:(NSTimeInterval)interval {
    if (self.asset == nil) { return; }

    CMTime currentTime = self.player.currentTime;
    CMTime offset = CMTimeMakeWithSeconds(interval, 1);
    
    CMTime newTime = CMTimeSubtract(currentTime, offset);
    [self.player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self updatePlaybackRateMetadata];
    }];
}

- (void)seekToPosition:(NSTimeInterval)position {
    if (self.asset == nil) { return; }

    CMTime newPosition = CMTimeMakeWithSeconds(position, 1);
    [self.player seekToTime:newPosition toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self updatePlaybackRateMetadata];
    }];
}

- (void)beginRewind {
    if (self.asset == nil) { return; }
    
    self.player.rate = -2.0;
}

- (void)beginFastForward {
    if (self.asset == nil) { return; }
    
    self.player.rate = 2.0;
}

- (void)endRewindFastForward {
    if (self.asset == nil) { return; }
    
    self.player.rate = 1.0;
}

- (void)updateGeneralMetadata {
    if (self.player.currentItem == nil) {
        self.nowPlayingInfoCenter.nowPlayingInfo = nil;
        return;
    }

    NSMutableDictionary *nowPlayingInfo;
    if ([self.nowPlayingInfoCenter.nowPlayingInfo isKindOfClass:[NSDictionary class]]) {
        nowPlayingInfo = [[NSMutableDictionary alloc] initWithDictionary:self.nowPlayingInfoCenter.nowPlayingInfo];
    } else {
        nowPlayingInfo = [[NSMutableDictionary alloc] init];
    }

    AVAsset *urlAsset = self.player.currentItem.asset;
    id value = [[AVMetadataItem metadataItemsFromArray:urlAsset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon] firstObject].value;
    NSString *title = [value isKindOfClass:[NSString class]] ? value : self.asset.assetName;
    
    value = [[AVMetadataItem metadataItemsFromArray:urlAsset.commonMetadata withKey:AVMetadataCommonKeyAlbumName keySpace:AVMetadataKeySpaceCommon] firstObject].value;
    NSString *album = [value isKindOfClass:[NSString class]] ? value : @"Unknown";

    [nowPlayingInfo setObject:title forKey:MPMediaItemPropertyTitle];
    [nowPlayingInfo setObject:album forKey:MPMediaItemPropertyAlbumTitle];

    if (@available(iOS 10.0, *)) {
        value = [[AVMetadataItem metadataItemsFromArray:urlAsset.commonMetadata withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon] firstObject].value;
        NSData *artworkData = [value isKindOfClass:[NSData class]] ? value : [[NSData alloc] init];
        UIImage *image = [UIImage imageWithData:artworkData];
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return image;
        }];
        
        [nowPlayingInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
    }

    self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo;
}

- (void)updatePlaybackRateMetadata {
    AVPlayerItem *currentItem = self.player.currentItem;
    if (currentItem == nil) {
        self.nowPlayingInfoCenter.nowPlayingInfo = nil;
        return;
    }

    NSMutableDictionary *nowPlayingInfo;
    if ([self.nowPlayingInfoCenter.nowPlayingInfo isKindOfClass:[NSDictionary class]]) {
        nowPlayingInfo = [[NSMutableDictionary alloc] initWithDictionary:self.nowPlayingInfoCenter.nowPlayingInfo];
    } else {
        nowPlayingInfo = [[NSMutableDictionary alloc] init];
    }
    
    self.duration = CMTimeGetSeconds(self.player.currentItem.duration);
    Float64 currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    Float32 rate = self.player.rate;

    [nowPlayingInfo setObject:[NSNumber numberWithFloat:self.duration] forKey:MPMediaItemPropertyPlaybackDuration];
    [nowPlayingInfo setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [nowPlayingInfo setObject:[NSNumber numberWithFloat:rate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [nowPlayingInfo setObject:[NSNumber numberWithFloat:rate] forKey:MPNowPlayingInfoPropertyDefaultPlaybackRate];
    
    self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo;
    
    if (self.player.rate == 0.0) {
        self.state = PlaybackStatePaused;
    } else {
        self.state = PlaybackStatePlaying;
    }
}
    
+ (NSString *)nextTrackNotification {
    return @"nextTrackNotification";
}

+ (NSString *)previousTrackNotification {
    return @"previousTrackNotification";
}

+ (NSString *)currentAssetDidChangeNotification {
    return @"currentAssetDidChangeNotification";
}

+ (NSString *)playerRateDidChangeNotification {
    return @"playerRateDidChangeNotification";
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {

    //willSet
    if (self.playerItem != nil) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[AVAudioSession sharedInstance]];
    }
    
    _playerItem = playerItem;
 
    //didSet
   if (self.playerItem != nil) {
        [_playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionInitial + NSKeyValueObservingOptionNew) context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    }
}

- (void)setAsset:(Asset *)asset {
    
    //willSet
    if (self.asset != nil) {
        [self.asset.urlAsset removeObserver:self forKeyPath:@"playable"];
    }
    
    _asset = asset;
    
    //didSet
    if (self.asset != nil) {
        [self.asset.urlAsset addObserver:self forKeyPath:@"playable" options:(NSKeyValueObservingOptionInitial + NSKeyValueObservingOptionNew) context:nil];
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
            self.state = PlaybackStateInterrupted;
            break;
        }
            
        case AVAudioSessionInterruptionTypeEnded: {
            @try {
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            } @catch (NSException *exception) {
                NSLog(@"An Error occured activating the audio session while resuming from interruption: %@", [exception description]);
            }
            
            if (self.shouldResumePlaybackAfterInterruption == NO) {
                self.shouldResumePlaybackAfterInterruption = YES;
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
    if ([object isKindOfClass:[AVURLAsset class]] && (AVURLAsset *)object == _asset.urlAsset && [keyPath isEqualToString:@"playable"]) {
        if (self.asset.urlAsset.isPlayable) {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:_asset.urlAsset];
            [self setPlayerItem:playerItem];
            [self.player replaceCurrentItemWithPlayerItem:playerItem];
        }
    } else if ([object isKindOfClass:[AVPlayerItem class]] && (AVPlayerItem *)object == _playerItem && [keyPath isEqualToString:@"status"]) {
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }
    } else if ([object isKindOfClass:[AVPlayer class]] && (AVPlayer *)object == _player && [keyPath isEqualToString:@"currentItem"]) {
        
        // Cleanup if needed.
        if (self.player.currentItem == nil) {
            self.asset = nil;
            self.playerItem = nil;
        }
        [self updateGeneralMetadata];
    } else if ([object isKindOfClass:[AVPlayer class]] && (AVPlayer *)object == _player && [keyPath isEqualToString:@"rate"]) {
        [self updatePlaybackRateMetadata];
        [[NSNotificationCenter defaultCenter] postNotificationName:AssetPlaybackManager.playerRateDidChangeNotification object:nil];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
