//
//  RemoteCommandManager.m
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "RemoteCommandManager.h"


@interface RemoteCommandManager ()

// MARK: Private properties
/// Reference of `MPRemoteCommandCenter` used to configure and setup remote control events in the application.
@property (nonatomic, strong) MPRemoteCommandCenter *remoteCommandCenter;

@end

@implementation RemoteCommandManager

- (instancetype)initWithAssetPlaybackManager:(AssetPlaybackManager *)assetPlaybackManager {
    self = [super init];
    if (self != nil) {
        self.remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        self.assetPlaybackManager = assetPlaybackManager;
    }
    return self;
}

-(void)dealloc {
    [self activatePlaybackCommands:false];
    [self toggleNextTrackCommand:false];
    [self togglePreviousTrackCommand:false];
    [self toggleSkipForwardCommand:false];
    [self toggleSkipBackwardCommand:false];
    [self toggleSeekForwardCommand:false];
    [self toggleChangePlaybackPositionCommand:false];
    [self toggleLikeCommand:false];
    [self toggleDislikeCommand:false];
    [self toggleBookmarkCommand:false];
}

- (void)activatePlaybackCommands:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.playCommand addTarget:self action:@selector(handlePlayCommandEvent:)];
        [self.remoteCommandCenter.pauseCommand addTarget:self action:@selector(handlePauseCommandEvent:)];
        [self.remoteCommandCenter.stopCommand addTarget:self action:@selector(handleStopCommandEvent:)];
        [self.remoteCommandCenter.togglePlayPauseCommand addTarget:self action:@selector(handleTogglePlayPauseCommandEvent:)];
    } else {
        [self.remoteCommandCenter.playCommand removeTarget:self action:@selector(handlePlayCommandEvent:)];
        [self.remoteCommandCenter.pauseCommand removeTarget:self action:@selector(handlePauseCommandEvent:)];
        [self.remoteCommandCenter.stopCommand removeTarget:self action:@selector(handleStopCommandEvent:)];
        [self.remoteCommandCenter.togglePlayPauseCommand removeTarget:self action:@selector(handleTogglePlayPauseCommandEvent:)];

    }
    
    [self.remoteCommandCenter.playCommand setEnabled:enable];
    [self.remoteCommandCenter.pauseCommand setEnabled:enable];
    [self.remoteCommandCenter.stopCommand setEnabled:enable];
    [self.remoteCommandCenter.togglePlayPauseCommand setEnabled:enable];
}

- (void)toggleNextTrackCommand:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.nextTrackCommand addTarget:self action:@selector(handleNextTrackCommandEvent:)];
    }
    else {
        [self.remoteCommandCenter.nextTrackCommand removeTarget:self action:@selector(handleNextTrackCommandEvent:)];
    }
    
    [self.remoteCommandCenter.nextTrackCommand setEnabled:enable];
}

- (void)togglePreviousTrackCommand:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.previousTrackCommand addTarget:self action:@selector(handleNextTrackCommandEvent:)];
    }
    else {
        [self.remoteCommandCenter.previousTrackCommand removeTarget:self action:@selector(handleNextTrackCommandEvent:)];
    }
    
    [self.remoteCommandCenter.previousTrackCommand setEnabled:enable];
}

- (void)toggleSkipForwardCommand:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.skipForwardCommand setPreferredIntervals:@[[NSNumber numberWithInt:0]]];
        [self.remoteCommandCenter.skipForwardCommand addTarget:self action:@selector(handleSkipForwardCommandEvent:)];
    } else {
        [self.remoteCommandCenter.skipForwardCommand removeTarget:self action:@selector(handleSkipForwardCommandEvent:)];
    }
    
    [self.remoteCommandCenter.skipForwardCommand setEnabled:enable];
}

- (void)toggleSkipBackwardCommand:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.skipBackwardCommand setPreferredIntervals:@[[NSNumber numberWithInt:0]]];
        [self.remoteCommandCenter.skipBackwardCommand addTarget:self action:@selector(handleSkipBackwardCommandEvent:)];
    } else {
        [self.remoteCommandCenter.skipBackwardCommand removeTarget:self action:@selector(handleSkipBackwardCommandEvent:)];
    }
    
    [self.remoteCommandCenter.skipForwardCommand setEnabled:enable];
}

- (void)toggleSeekForwardCommand:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.seekForwardCommand addTarget:self action:@selector(handleSeekForwardCommandEvent:)];
    } else {
        [self.remoteCommandCenter.seekForwardCommand removeTarget:self action:@selector(handleSeekForwardCommandEvent:)];
    }
    
    [self.remoteCommandCenter.seekForwardCommand setEnabled:enable];
}

- (void)toggleChangePlaybackPositionCommand:(BOOL)enable {
    if (@available(iOS 9.1, *)) {
        if (enable) {
            [self.remoteCommandCenter.changePlaybackPositionCommand addTarget:self action:@selector(handleChangePlaybackPositionCommandEvent:)];
        } else {
            [self.remoteCommandCenter.changePlaybackPositionCommand removeTarget:self action:@selector(handleChangePlaybackPositionCommandEvent:)];
        }
        
        [self.remoteCommandCenter.changePlaybackPositionCommand setEnabled:enable];
    }
}

- (void)toggleLikeCommand:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.likeCommand addTarget:self action:@selector(handleLikeCommandEvent:)];
    } else {
        [self.remoteCommandCenter.likeCommand removeTarget:self action:@selector(handleLikeCommandEvent:)];
    }
    
    [self.remoteCommandCenter.likeCommand setEnabled:enable];
}

- (void)toggleDislikeCommand:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.dislikeCommand addTarget:self action:@selector(handleDislikeCommandEvent:)];
    } else {
        [self.remoteCommandCenter.dislikeCommand removeTarget:self action:@selector(handleDislikeCommandEvent:)];
    }
    
    [self.remoteCommandCenter.dislikeCommand setEnabled:enable];
}

- (void)toggleBookmarkCommand:(BOOL)enable {
    if (enable) {
        [self.remoteCommandCenter.bookmarkCommand addTarget:self action:@selector(handleBookmarkCommandEvent:)];
    } else {
        [self.remoteCommandCenter.bookmarkCommand removeTarget:self action:@selector(handleBookmarkCommandEvent:)];
    }
    
    [self.remoteCommandCenter.bookmarkCommand setEnabled:enable];
}

// MARK: MPRemoteCommand handler methods.
// MARK: Playback Command Handlers
- (MPRemoteCommandHandlerStatus)handlePlayCommandEvent:(MPRemoteCommandEvent *)event {
    [self.assetPlaybackManager play];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePauseCommandEvent:(MPRemoteCommandEvent *)event {
    [self.assetPlaybackManager pause];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleStopCommandEvent:(MPRemoteCommandEvent *)event {
    [self.assetPlaybackManager stop];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleTogglePlayPauseCommandEvent:(MPRemoteCommandEvent *)event {
    [self.assetPlaybackManager togglePlayPause];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleNextTrackCommandEvent:(MPRemoteCommandEvent *)event {
    if (self.assetPlaybackManager.asset != nil) {
        [self.assetPlaybackManager nextTrack];
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

- (MPRemoteCommandHandlerStatus)handlePreviousTrackCommandEvent:(MPRemoteCommandEvent *)event {
    if (self.assetPlaybackManager.asset != nil) {
        [self.assetPlaybackManager previousTrack];
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

// MARK: Skip Interval Command Handlers
- (MPRemoteCommandHandlerStatus)handleSkipForwardCommandEvent:(MPSkipIntervalCommandEvent *)event {
    [self.assetPlaybackManager skipForwardWithTimeInterval:event.interval];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleSkipBackwardCommandEvent:(MPSkipIntervalCommandEvent *)event {
    [self.assetPlaybackManager skipBackwardWithTimeInterval:event.interval];
    return MPRemoteCommandHandlerStatusSuccess;
}

// MARK: Seek Command Handlers
- (MPRemoteCommandHandlerStatus)handleSeekForwardCommandEvent:(MPSeekCommandEvent *)event {
    switch (event.type) {
        case MPSeekCommandEventTypeBeginSeeking:
            [self.assetPlaybackManager beginFastForward];
            break;
            
        case MPSeekCommandEventTypeEndSeeking:
            [self.assetPlaybackManager endRewindFastForward];
            break;
            
        default:
            break;
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleSeekBackwardCommandEvent:(MPSeekCommandEvent *)event {
    switch (event.type) {
        case MPSeekCommandEventTypeBeginSeeking:
            [self.assetPlaybackManager beginRewind];
            break;
            
        case MPSeekCommandEventTypeEndSeeking:
            [self.assetPlaybackManager endRewindFastForward];
            break;
            
        default:
            break;
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleChangePlaybackPositionCommandEvent:(MPChangePlaybackPositionCommandEvent *)event {
    [self.assetPlaybackManager seekToPosition:event.positionTime];
    return MPRemoteCommandHandlerStatusSuccess;
}

// MARK: Feedback Command Handlers
- (MPRemoteCommandHandlerStatus)handleLikeCommandEvent:(MPFeedbackCommandEvent *)event {
    if (self.assetPlaybackManager.asset != nil) {
        NSLog(@"Did recieve likeCommand for: %@", self.assetPlaybackManager.asset.assetName);
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

- (MPRemoteCommandHandlerStatus)handleDislikeCommandEvent:(MPFeedbackCommandEvent *)event {
    if (self.assetPlaybackManager.asset != nil) {
        NSLog(@"Did recieve dislikeCommand for: %@", self.assetPlaybackManager.asset.assetName);
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

- (MPRemoteCommandHandlerStatus)handleBookmarkCommandEvent:(MPFeedbackCommandEvent *)event {
    if (self.assetPlaybackManager.asset != nil) {
        NSLog(@"Did recieve bookmarkCommand for: %@", self.assetPlaybackManager.asset.assetName);
        return MPRemoteCommandHandlerStatusSuccess;
    } else {
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }
}

@end
