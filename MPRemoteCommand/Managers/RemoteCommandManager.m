//
//  RemoteCommandManager.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "RemoteCommandManager.h"

@implementation RemoteCommandManager

-(instancetype)initWithAssetPlaybackManager:(AssetPlaybackManager *)assetPlaybackManager {
    self = [super init];
    if (self != nil) {
        remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        self->assetPlaybackManager = assetPlaybackManager;
    }
    return self;
}

@end
