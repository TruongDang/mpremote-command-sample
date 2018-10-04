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

@end
