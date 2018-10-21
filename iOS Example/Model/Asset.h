//
//  Asset.h
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Asset : NSObject

// MARK: Types
@property (class, nonatomic, readonly) NSString *nameKey;

// MARK: Properties
/// The name of the asset to present in the application.
@property (nonatomic, strong) NSString *assetName;

/// The `AVURLAsset` corresponding to an asset in either the application bundle or on the Internet.
@property (nonatomic, strong) AVURLAsset *urlAsset;

- (instancetype)initWithName:(NSString *)assetName URL:(AVURLAsset *)urlAsset;

@end

NS_ASSUME_NONNULL_END
