//
//  RemoteCommandManager.h
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AssetPlaybackManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RemoteCommandManager : NSObject

// MARK: Public properties
/// The instance of `AssetPlaybackManager` to use for responding to remote command events.
@property (nonatomic, strong) AssetPlaybackManager *assetPlaybackManager;

- (instancetype)initWithAssetPlaybackManager:(AssetPlaybackManager *)assetPlaybackManager;

- (void)activatePlaybackCommands:(BOOL)enable;

- (void)toggleNextTrackCommand:(BOOL)enable;

- (void)togglePreviousTrackCommand:(BOOL)enable;

- (void)toggleSkipForwardCommand:(BOOL)enable;

- (void)toggleSkipBackwardCommand:(BOOL)enable;

- (void)toggleSeekForwardCommand:(BOOL)enable;

- (void)toggleChangePlaybackPositionCommand:(BOOL)enable;

- (void)toggleLikeCommand:(BOOL)enable;

- (void)toggleDislikeCommand:(BOOL)enable;

- (void)toggleBookmarkCommand:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
