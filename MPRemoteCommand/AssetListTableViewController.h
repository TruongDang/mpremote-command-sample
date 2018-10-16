//
//  AssetListTableViewController.h
//  ios-app
//
//  Created by Đặng Văn Trường on 10/3/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AssetPlaybackManager.h"

@interface AssetListTableViewController : UITableViewController
// MARK: Properties

/// An array of `Asset` objects representing the m4a files used for playback in this sample.
@property (strong, nonatomic)  NSMutableArray *assets;

/// The instance of `AssetPlaybackManager` to use for playing an `Asset`.
@property (strong, nonatomic)  AssetPlaybackManager *assetPlaybackManager;



@end
