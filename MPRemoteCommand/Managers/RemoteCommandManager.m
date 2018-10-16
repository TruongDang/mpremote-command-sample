//
//  RemoteCommandManager.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "RemoteCommandManager.h"

@implementation RemoteCommandManager

-(instancetype)initWithAssetPlaybackManager:(AssetPlaybackManager *)anAssetPlaybackManager {
    self = [super init];
    if (self != nil) {
        remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        assetPlaybackManager = anAssetPlaybackManager;
    }
    return self;
}

-(void)dealloc {
    [self activatePlaybackCommands:false];
    [self toggleNextTrackCommand:true];
    [self togglePreviousTrackCommand:true];
    [self toggleSkipForwardCommand:false];
    [self toggleSkipBackwardCommand:false];
    [self toggleSeekForwardCommand:false];
    [self toggleSeekBackwardCommand:false];
    [self toggleChangePlaybackPositionCommand:false];
    [self toggleLikeCommand:false];
    [self toggleDislikeCommand:false];
    [self toggleBookmarkCommand:false];
}

-(void)activatePlaybackCommands:(BOOL)enable {
    if (enable) {
        [remoteCommandCenter.playCommand addTarget:self action:@selector(handlePlayCommandEvent:)];
        [remoteCommandCenter.pauseCommand addTarget:self action:@selector(handlePauseCommandEvent:)];
        [remoteCommandCenter.stopCommand addTarget:self action:@selector(handleStopCommandEvent:)];
        [remoteCommandCenter.togglePlayPauseCommand addTarget:self action:@selector(handleTogglePlayPauseCommandEvent:)];
    } else {
        [remoteCommandCenter.playCommand removeTarget:self action:@selector(handlePlayCommandEvent:)];
        [remoteCommandCenter.pauseCommand removeTarget:self action:@selector(handlePauseCommandEvent:)];
        [remoteCommandCenter.stopCommand removeTarget:self action:@selector(handleStopCommandEvent:)];
        [remoteCommandCenter.togglePlayPauseCommand removeTarget:self action:@selector(handleTogglePlayPauseCommandEvent:)];
    }
    [remoteCommandCenter.playCommand setEnabled:enable];
    [remoteCommandCenter.pauseCommand setEnabled:enable];
    [remoteCommandCenter.stopCommand setEnabled:enable];
    [remoteCommandCenter.togglePlayPauseCommand setEnabled:enable];
}

-(void)toggleNextTrackCommand:(BOOL)enable {
    if (enable) {
        [remoteCommandCenter.nextTrackCommand addTarget:self action:@selector(handleNextTrackCommandEvent:)];
    } else {
        [remoteCommandCenter.nextTrackCommand removeTarget:self action:@selector(handleNextTrackCommandEvent:)];
    }
    [remoteCommandCenter.nextTrackCommand setEnabled:enable];
}

-(void)togglePreviousTrackCommand:(BOOL)enable {
    if (enable) {
        [remoteCommandCenter.previousTrackCommand addTarget:self action:@selector(handlePreviousTrackCommandEvent:)];
    } else {
        [remoteCommandCenter.previousTrackCommand removeTarget:self action:@selector(handlePreviousTrackCommandEvent:)];
    }
    [remoteCommandCenter.previousTrackCommand setEnabled:enable];
}

-(void)toggleSkipForwardCommand:(BOOL)enable {
    if (enable) {
        remoteCommandCenter.skipForwardCommand.preferredIntervals = @[[NSNumber numberWithInt:0]];
        [remoteCommandCenter.skipForwardCommand addTarget:self action:@selector(handleSkipForwardCommandEvent:)];
    } else {
        [remoteCommandCenter.skipForwardCommand removeTarget:self action:@selector(handleSkipForwardCommandEvent:)];
    }
    
    [remoteCommandCenter.skipForwardCommand setEnabled:enable];
}

-(void)toggleSkipBackwardCommand:(BOOL)enable {
    if (enable) {
        remoteCommandCenter.skipBackwardCommand.preferredIntervals = @[[NSNumber numberWithInt:0]];
        [remoteCommandCenter.skipBackwardCommand addTarget:self action:@selector(handleSkipBackwardCommandEvent:)];
    } else {
        [remoteCommandCenter.skipBackwardCommand removeTarget:self action:@selector(handleSkipBackwardCommandEvent:)];
    }
    
    [remoteCommandCenter.skipBackwardCommand setEnabled:enable];
}

-(void)toggleSeekForwardCommand:(BOOL)enable {
    if (enable) {
        [remoteCommandCenter.seekForwardCommand addTarget:self action:@selector(handleSeekForwardCommandEvent:)];
    } else {
        [remoteCommandCenter.seekForwardCommand removeTarget:self action:@selector(handleSeekForwardCommandEvent:)];
    }
    
    [remoteCommandCenter.seekForwardCommand setEnabled:enable];
}

-(void)toggleSeekBackwardCommand:(BOOL)enable {
    if (enable) {
        [remoteCommandCenter.seekBackwardCommand addTarget:self action:@selector(handleSeekBackwardCommandEvent:)];
    } else {
        [remoteCommandCenter.seekBackwardCommand removeTarget:self action:@selector(handleSeekBackwardCommandEvent:)];
    }
    
    [remoteCommandCenter.seekBackwardCommand setEnabled:enable];
}

-(void)toggleChangePlaybackPositionCommand:(BOOL)enable {
    if (@available(iOS 9.1, *)) {
        if (enable) {
            [remoteCommandCenter.changePlaybackPositionCommand addTarget:self action:@selector(handleChangePlaybackPositionCommandEvent:)];
        } else {
            [remoteCommandCenter.changePlaybackPositionCommand removeTarget:self action:@selector(handleChangePlaybackPositionCommandEvent:)];
        }
        
        [remoteCommandCenter.changePlaybackPositionCommand setEnabled:enable];
    }
}

-(void)toggleLikeCommand:(BOOL)enable {
    if (enable) {
        [remoteCommandCenter.likeCommand addTarget:self action:@selector(handleLikeCommandEvent:)];
    } else {
        [remoteCommandCenter.likeCommand removeTarget:self action:@selector(handleLikeCommandEvent:)];
    }
    
    [remoteCommandCenter.likeCommand setEnabled:enable];
}

-(void)toggleDislikeCommand:(BOOL)enable {
    if (enable) {
        [remoteCommandCenter.dislikeCommand addTarget:self action:@selector(handleDislikeCommandEvent:)];
    } else {
        [remoteCommandCenter.dislikeCommand removeTarget:self action:@selector(handleDislikeCommandEvent:)];
    }
    
    [remoteCommandCenter.dislikeCommand setEnabled:enable];
}

-(void)toggleBookmarkCommand:(BOOL)enable {
    if (enable) {
        [remoteCommandCenter.bookmarkCommand addTarget:self action:@selector(handleBookmarkCommandEvent:)];
    } else {
        [remoteCommandCenter.bookmarkCommand removeTarget:self action:@selector(handleBookmarkCommandEvent:)];
    }
    
    [remoteCommandCenter.bookmarkCommand setEnabled:enable];
}

// MARK: MPRemoteCommand handler methods.

// MARK: Playback Command Handlers
- (MPRemoteCommandHandlerStatus)handlePauseCommandEvent:(MPRemoteCommandEvent *)event {
    [assetPlaybackManager pause];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePlayCommandEvent:(MPRemoteCommandEvent *)event {
    [assetPlaybackManager play];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleStopCommandEvent:(MPRemoteCommandEvent *)event {
    [assetPlaybackManager stop];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleTogglePlayPauseCommandEvent:(MPRemoteCommandEvent *)event {
    [assetPlaybackManager togglePlayPause];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleNextTrackCommandEvent:(MPRemoteCommandEvent *)event {
    if (assetPlaybackManager.asset != nil) {
        [assetPlaybackManager nextTrack];
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

- (MPRemoteCommandHandlerStatus)handlePreviousTrackCommandEvent:(MPRemoteCommandEvent *)event {
    if (assetPlaybackManager.asset != nil) {
        [assetPlaybackManager previousTrack];
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

// MARK: Skip Interval Command Handlers
- (MPRemoteCommandHandlerStatus)handleSkipForwardCommandEvent:(MPSkipIntervalCommandEvent *)event {
    [assetPlaybackManager skipForwardWithTimeInterval:event.interval];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleSkipBackwardCommandEvent:(MPSkipIntervalCommandEvent *)event {
    [assetPlaybackManager skipBackwardWithTimeInterval:event.interval];
    return MPRemoteCommandHandlerStatusSuccess;
}

// MARK: Seek Command Handlers
- (MPRemoteCommandHandlerStatus)handleSeekForwardCommandEvent:(MPSeekCommandEvent *)event {
    switch (event.type) {
        case MPSeekCommandEventTypeBeginSeeking:
            [assetPlaybackManager beginFastForward];
            break;
            
        case MPSeekCommandEventTypeEndSeeking:
            [assetPlaybackManager endRewindFastForward];
            break;
            
        default:
            break;
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleSeekBackwardCommandEvent:(MPSeekCommandEvent *)event {
    switch (event.type) {
        case MPSeekCommandEventTypeBeginSeeking:
            [assetPlaybackManager beginRewind];
            break;
            
        case MPSeekCommandEventTypeEndSeeking:
            [assetPlaybackManager endRewindFastForward];
            break;
            
        default:
            break;
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleChangePlaybackPositionCommandEvent:(MPChangePlaybackPositionCommandEvent *)event {
    [assetPlaybackManager seekToPosition:event.positionTime];
    return MPRemoteCommandHandlerStatusSuccess;
}

// MARK: Feedback Command Handlers
- (MPRemoteCommandHandlerStatus)handleLikeCommandEvent:(MPFeedbackCommandEvent *)event {
    if (assetPlaybackManager.asset != nil) {
        NSLog(@"Did recieve likeCommand for: %@", assetPlaybackManager.asset.assetName);
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

- (MPRemoteCommandHandlerStatus)handleDislikeCommandEvent:(MPFeedbackCommandEvent *)event {
    if (assetPlaybackManager.asset != nil) {
        NSLog(@"Did recieve dislikeCommand for: %@", assetPlaybackManager.asset.assetName);
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

- (MPRemoteCommandHandlerStatus)handleBookmarkCommandEvent:(MPFeedbackCommandEvent *)event {
    if (assetPlaybackManager.asset != nil) {
        NSLog(@"Did recieve bookmarkCommand for: %@", assetPlaybackManager.asset.assetName);
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

@end
