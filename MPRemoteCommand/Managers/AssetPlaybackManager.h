//
//  AssetPlaybackManager.h
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Asset.h"

/// Notification that is posted when the `nextTrack()` is called.
extern NSString *const kNextTrackNotification;

/// Notification that is posted when the `previousTrack()` is called.
extern NSString *const kPreviousTrackNotification;

/// Notification that is posted when currently playing `Asset` did change.
extern NSString *const kCurrentAssetDidChangeNotification;

/// Notification that is posted when the internal AVPlayer rate did change.
extern NSString *const kPlayerRateDidChangeNotification;

/// An enumeration of possible playback states that `AssetPlaybackManager` can be in.
typedef NS_ENUM(NSUInteger , PlaybackState) {
    PlaybackStateInitial,    /// - initial: The playback state that `AssetPlaybackManager` starts in when nothing is playing.
    PlaybackStatePlaying,    /// - playing: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` != 0.
    PlaybackStatePaused,    /// - paused: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` == 0.
    PlaybackStateInterrupted    /// - interrupted: The playback state that `AssetPlaybackManager` is in when audio is interrupted.
};

@interface AssetPlaybackManager : NSObject {
    // MARK: Types
    
    /// The state that the internal `AVPlayer` is in.
    PlaybackState state;

    
    // MARK: Properties
    
    /// The instance of `MPNowPlayingInfoCenter` that is used for updating metadata for the currently playing `Asset`.
    MPNowPlayingInfoCenter *nowPlayingInfoCenter;
    
    /// A token obtained from calling `player`'s `addPeriodicTimeObserverForInterval(_:queue:usingBlock:)` method.
    id timeObserverToken;
    
    
    /// The total duration in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    Float64 duration;

    /// A Bool for tracking if playback should be resumed after an interruption.  See README.md for more information.
    BOOL shouldResumePlaybackAfterInterruption;
}

/// The progress in percent for the playback of `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
@property (nonatomic) Float64 percentProgress;

/// The current playback position in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
@property (nonatomic) Float64 playbackPosition;

/// The instance of AVPlayer that will be used for playback of AssetPlaybackManager.playerItem.
@property (strong, nonatomic) AVPlayer *player;

/// The AVPlayerItem associated with AssetPlaybackManager.asset.urlAsset
@property (strong, nonatomic) AVPlayerItem *playerItem;

/// The Asset that is currently being loaded for playback.
@property (strong, nonatomic) Asset *asset;

- (void)pause;
- (void)play;
- (void)stop;
- (void)togglePlayPause;
- (void)nextTrack;
- (void)previousTrack;
- (void)skipForwardWithTimeInterval:(NSTimeInterval)interval;
- (void)skipBackwardWithTimeInterval:(NSTimeInterval)interval;
- (void)seekToPosition:(NSTimeInterval)position;
- (void)beginFastForward;
- (void)beginRewind;
- (void)endRewindFastForward;
@end
