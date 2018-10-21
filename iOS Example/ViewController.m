//
//  ViewController.m
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray<Asset *> *songList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [songListTableView setDataSource:self];
    [songListTableView setDelegate:self];
    self.songList = [[NSMutableArray alloc] init];

    // Populate `assetListTableView` with all the m4a files in the Application bundle.
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[[NSBundle mainBundle] bundleURL] includingPropertiesForKeys:nil options:0 errorHandler:nil];
    for (NSURL *url in enumerator) {
        if ([url.pathExtension isEqualToString:@"m4a"]) {
            NSString *fileName = url.lastPathComponent;
            [self.songList addObject:[[Asset alloc] initWithName:fileName URL:[[AVURLAsset alloc] initWithURL:url options:nil]]];
        }
    }

    // Add the notification observers needed to respond to events from the `AssetPlaybackManager`.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteCommandNextTrackNotification:) name:AssetPlaybackManager.nextTrackNotification object:nil];
}

// MARK: UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    Asset *song = [self.songList objectAtIndex:indexPath.row];
    cell.textLabel.text = song.assetName;
    return cell;
}

// MARK: UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Asset *asset = [self.songList objectAtIndex:indexPath.row];
    
    self.assetPlaybackManager.asset = asset;
}

// MARK: Notification Handler Methods
- (void)handleRemoteCommandNextTrackNotification:(NSNotification *)notification {
    NSString *assetName = [notification.userInfo objectForKey:Asset.nameKey];
    NSInteger assetIndex = NSNotFound;
    for (Asset *asset in self.songList) {
        if ([asset.assetName isEqualToString:assetName]) {
            assetIndex = [self.songList indexOfObject:asset];
        }
    }
    
    if ((assetIndex != NSNotFound) && (assetIndex < self.songList.count - 1)) {
        self.assetPlaybackManager.asset = [self.songList objectAtIndex:(assetIndex + 1)];
    }
}

- (void)handleRemoteCommandPreviousTrackNotification:(NSNotification *)notification {
    NSString *assetName = [notification.userInfo objectForKey:Asset.nameKey];
    NSInteger assetIndex = NSNotFound;
    for (Asset *asset in self.songList) {
        if ([asset.assetName isEqualToString:assetName]) {
            assetIndex = [self.songList indexOfObject:asset];
        }
    }
    
    if ((assetIndex != NSNotFound) && (assetIndex > 0)) {
        self.assetPlaybackManager.asset = [self.songList objectAtIndex:(assetIndex + 1)];
    }
}
@end
