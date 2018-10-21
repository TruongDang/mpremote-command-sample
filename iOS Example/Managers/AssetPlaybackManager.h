//
//  AssetPlaybackManager.h
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Asset.h"

// MARK: Types
/// An enumeration of possible playback states that `AssetPlaybackManager` can be in.
typedef NS_ENUM(NSUInteger , AssetPlaybackManagerState) {
    PlaybackStateInitial,    /// - initial: The playback state that `AssetPlaybackManager` starts in when nothing is playing.
    PlaybackStatePlaying,    /// - playing: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` != 0.
    PlaybackStatePaused,    /// - paused: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` == 0.
    PlaybackStateInterrupted    /// - interrupted: The playback state that `AssetPlaybackManager` is in when audio is interrupted.
};

NS_ASSUME_NONNULL_BEGIN

@interface AssetPlaybackManager : NSObject

// MARK: Types
@property (class, nonatomic, readonly) NSString *nextTrackNotification;

@property (class, nonatomic, readonly) NSString *previousTrackNotification;

@property (class, nonatomic, readonly) NSString *currentAssetDidChangeNotification;

@property (class, nonatomic, readonly) NSString *playerRateDidChangeNotification;

// MARK: Public properties
/// The instance of AVPlayer that will be used for playback of AssetPlaybackManager.playerItem.
@property (nonatomic, strong) AVPlayer *player;

/// The Asset that is currently being loaded for playback.
@property (nonatomic, strong, nullable) Asset *asset;

- (void)play;
- (void)pause;
- (void)stop;
- (void)togglePlayPause;
- (void)nextTrack;
- (void)previousTrack;
- (void)skipForwardWithTimeInterval:(NSTimeInterval)interval;
- (void)skipBackwardWithTimeInterval:(NSTimeInterval)interval;
- (void)beginFastForward;
- (void)beginRewind;
- (void)endRewindFastForward;
- (void)seekToPosition:(NSTimeInterval)position;

@end

NS_ASSUME_NONNULL_END
