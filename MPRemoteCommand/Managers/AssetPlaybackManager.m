//
//  AssetPlaybackManager.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "AssetPlaybackManager.h"

@implementation AssetPlaybackManager

-(instancetype)init {
    self = [super init];
    if (self != nil) {
        nextTrackNotification = [NSNotification notificationWithName:@"nextTrackNotification" object:nil];
        previousTrackNotification = [NSNotification notificationWithName:@"previousTrackNotification" object:nil];
        currentAssetDidChangeNotification = [NSNotification notificationWithName:@"currentAssetDidChangeNotification" object:nil];
        playerRateDidChangeNotification = [NSNotification notificationWithName:@"playerRateDidChangeNotification" object:nil];
        player = [AVPlayer new];
        nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
        percentProgress = 0;
        duration = 0;
        playbackPosition = 0;
        shouldResumePlaybackAfterInterruption = YES;
    }
    return self;
}

@end
