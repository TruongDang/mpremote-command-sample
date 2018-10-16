//
//  AssetListTableViewController.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/3/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "AssetListTableViewController.h"

@implementation AssetListTableViewController

// MARK: View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Play" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList:)];
    self.navigationItem.rightBarButtonItem = anotherButton;

    _assetPlaybackManager = [[AssetPlaybackManager alloc] init];
    _assets = [NSMutableArray new];
    // Populate `assetListTableView` with all the m4a files in the Application bundle.
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[[NSBundle mainBundle] bundleURL] includingPropertiesForKeys:nil options:0 errorHandler:nil];
    for (NSURL *url in enumerator) {
        if ([url.pathExtension isEqualToString:@"m4a"]) {
            NSString *fileName = url.lastPathComponent;
           [_assets addObject:[[Asset alloc] initWithassetName:fileName urlAsset:[[AVURLAsset alloc] initWithURL:url options:nil]]];
        }
    }

    /*guard let enumerator = FileManager.default.enumerator(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil, options: [], errorHandler: nil) else { return }
    
    assets = enumerator.flatMap { element in
        guard let url = element as? URL, url.pathExtension == "m4a" else { return nil }
        
        let fileName = url.lastPathComponent
        return Asset(assetName: fileName, urlAsset: AVURLAsset(url: url))
    }*/
    
    // Add the notification observers needed to respond to events from the `AssetPlaybackManager`.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteCommandNextTrackNotification:) name:kNextTrackNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteCommandPreviousTrackNotification:) name:kPreviousTrackNotification object:nil];

    /*let notificationCenter = NotificationCenter.default
    
    notificationCenter.addObserver(self, selector: #selector(AssetListTableViewController.handleRemoteCommandNextTrackNotification(notification:)), name: AssetPlaybackManager.nextTrackNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(AssetListTableViewController.handleRemoteCommandPreviousTrackNotification(notification:)), name: AssetPlaybackManager.previousTrackNotification, object: nil)*/
}

- (void)dealloc {

    // Remove all notification observers.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    /*let notificationCenter = NotificationCenter.default
    
    notificationCenter.removeObserver(self, name: AssetPlaybackManager.nextTrackNotification, object: nil)
    notificationCenter.removeObserver(self, name: AssetPlaybackManager.previousTrackNotification, object: nil)*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [super numberOfSectionsInTableView:tableView];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [super tableView:tableView numberOfRowsInSection:section];
    return _assets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    Asset *asset = [_assets objectAtIndex:indexPath.row];
    [cell.textLabel setText:asset.assetName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Asset *asset = [_assets objectAtIndex:indexPath.row];
    
    _assetPlaybackManager.asset = asset;
}

- (void)refreshPropertyList:(id)object {    
    [_assetPlaybackManager play];
}

- (void)handleRemoteCommandNextTrackNotification:(NSNotification *)notification {
    NSString *assetName = [notification.userInfo objectForKey:kAssetNameKey];
    NSInteger assetIndex = NSNotFound;
    for (Asset *asset in _assets) {
        if ([asset.assetName isEqualToString:assetName]) {
            assetIndex = [_assets indexOfObject:asset];
        }
    }
    
    if ((assetIndex != NSNotFound) && (assetIndex < _assets.count - 1)) {
        _assetPlaybackManager.asset = _assets[assetIndex + 1];
    }
}

- (void)handleRemoteCommandPreviousTrackNotification:(NSNotification *)notification {
    NSString *assetName = [notification.userInfo objectForKey:kAssetNameKey];
    NSInteger assetIndex = NSNotFound;
    for (Asset *asset in _assets) {
        if ([asset.assetName isEqualToString:assetName]) {
            assetIndex = [_assets indexOfObject:asset];
        }
    }
    
    if ((assetIndex != NSNotFound) && (assetIndex > 0)) {
        _assetPlaybackManager.asset = _assets[assetIndex + 1];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
