//
//  RemoteCommandManager.h
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetPlaybackManager.h"

@interface RemoteCommandManager : NSObject {
    // MARK: Properties
    
    /// Reference of `MPRemoteCommandCenter` used to configure and setup remote control events in the application.
    MPRemoteCommandCenter *remoteCommandCenter;
    
    /// The instance of `AssetPlaybackManager` to use for responding to remote command events.
    AssetPlaybackManager *assetPlaybackManager;
}

-(instancetype)initWithAssetPlaybackManager:(AssetPlaybackManager *)assetPlaybackManager;

-(void)activatePlaybackCommands:(BOOL)enable;

-(void)toggleNextTrackCommand:(BOOL)enable;

-(void)togglePreviousTrackCommand:(BOOL)enable;

-(void)toggleSkipForwardCommand:(BOOL)enable;

-(void)toggleSkipBackwardCommand:(BOOL)enable;

-(void)toggleSeekForwardCommand:(BOOL)enable;

-(void)toggleSeekBackwardCommand:(BOOL)enable;

-(void)toggleChangePlaybackPositionCommand:(BOOL)enable;

-(void)toggleLikeCommand:(BOOL)enable;

-(void)toggleDislikeCommand:(BOOL)enable;

-(void)toggleBookmarkCommand:(BOOL)enable;

@end
