//
//  ViewController.h
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetPlaybackManager.h"
#import "RemoteCommandManager.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    __weak IBOutlet UITableView *songListTableView;
    
}

@property (nonatomic, strong) AssetPlaybackManager *assetPlaybackManager;
@property (nonatomic, strong) RemoteCommandManager *remoteCommandManager;

@end

