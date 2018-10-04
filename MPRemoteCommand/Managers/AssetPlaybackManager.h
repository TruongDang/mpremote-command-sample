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

/// An enumeration of possible playback states that `AssetPlaybackManager` can be in.
typedef NS_ENUM(NSUInteger , PlaybackState) {
    PlaybackStateInitial,    /// - initial: The playback state that `AssetPlaybackManager` starts in when nothing is playing.
    PlaybackStatePlaying,    /// - playing: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` != 0.
    PlaybackStatePaused,    /// - paused: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` == 0.
    PlaybackStateInterrupted    /// - interrupted: The playback state that `AssetPlaybackManager` is in when audio is interrupted.
};

@interface AssetPlaybackManager : NSObject {
    // MARK: Types
    
    /// Notification that is posted when the `nextTrack()` is called.
    NSNotification *nextTrackNotification;
    
    /// Notification that is posted when the `previousTrack()` is called.
    NSNotification *previousTrackNotification;
    
    /// The state that the internal `AVPlayer` is in.
    PlaybackState state;

    /// Notification that is posted when currently playing `Asset` did change.
    NSNotification *currentAssetDidChangeNotification;
    
    /// Notification that is posted when the internal AVPlayer rate did change.
    NSNotification *playerRateDidChangeNotification;
    
    // MARK: Properties
    
    /// The instance of AVPlayer that will be used for playback of AssetPlaybackManager.playerItem.
    AVPlayer *player;
    
    /// The instance of `MPNowPlayingInfoCenter` that is used for updating metadata for the currently playing `Asset`.
    MPNowPlayingInfoCenter *nowPlayingInfoCenter;
    
    /// A token obtained from calling `player`'s `addPeriodicTimeObserverForInterval(_:queue:usingBlock:)` method.
    id timeObserverToken;
    
    /// The progress in percent for the playback of `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    float percentProgress;
    
    /// The total duration in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    float duration;

    /// The current playback position in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    float playbackPosition;
    
    /// A Bool for tracking if playback should be resumed after an interruption.  See README.md for more information.
    BOOL shouldResumePlaybackAfterInterruption;
    
    /// The AVPlayerItem associated with AssetPlaybackManager.asset.urlAsset
    AVPlayerItem *playerItem;
    
    /// The Asset that is currently being loaded for playback.
    Asset *asset;
}

@end
