//
//  Asset.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "Asset.h"

NSString *const kAssetNameKey = @"AssetName";

@implementation Asset
- (instancetype)initWithassetName:(NSString *)assetName urlAsset:(AVURLAsset *)urlAsset {
    self = [super init];
    if (self != nil) {
        _assetName = assetName;
        _urlAsset = urlAsset;
    }
    return self;
}
@end
