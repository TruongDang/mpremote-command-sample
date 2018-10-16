//
//  Asset.h
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// MARK: Types
extern NSString *const kAssetNameKey;

@interface Asset : NSObject

/// The name of the asset to present in the application.
@property (strong, nonatomic) NSString *assetName;

/// The `AVURLAsset` corresponding to an asset in either the application bundle or on the Internet.
@property (strong, nonatomic) AVURLAsset *urlAsset;

- (instancetype)initWithassetName:(NSString *)assetName urlAsset:(AVURLAsset *)urlAsset;

@end
