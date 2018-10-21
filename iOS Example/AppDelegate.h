//
//  AppDelegate.h
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetPlaybackManager.h"
#import "RemoteCommandManager.h"
#import "ViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/// The instance of `AssetPlaybackManager` that the app uses for managing playback.
@property (strong, nonatomic) AssetPlaybackManager *assetPlaybackManager;

/// The instance of `RemoteCommandManager` that the app uses for managing remote command events.
@property (strong, nonatomic) RemoteCommandManager *remoteCommandManager;


@end

