//
//  AppDelegate.m
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initializer the `AssetPlaybackManager`.
    self.assetPlaybackManager = [[AssetPlaybackManager alloc] init];
    
    // Initializer the `RemoteCommandManager`.
    self.remoteCommandManager = [[RemoteCommandManager alloc] initWithAssetPlaybackManager:self.assetPlaybackManager];
    
    // Always enable playback commands in MPRemoteCommandCenter.
    [self.remoteCommandManager activatePlaybackCommands:true];
//    [self.remoteCommandManager toggleNextTrackCommand:true];
//    [self.remoteCommandManager togglePreviousTrackCommand:true];

    
    if (@available(iOS 10.0, *)) {
        @try {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:0 error:nil];
        } @catch (NSException *exception) {
            NSLog(@"An error occured setting the audio session category: %@", [exception description]);
        }
    }

    @try {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    } @catch (NSException *exception) {
        NSLog(@"An Error occured activating the audio session while resuming from interruption: %@", [exception description]);
    }

    
    ViewController *assetListTableViewController = (ViewController*)self.window.rootViewController;
    assetListTableViewController.assetPlaybackManager = self.assetPlaybackManager;
    assetListTableViewController.remoteCommandManager = self.remoteCommandManager;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
