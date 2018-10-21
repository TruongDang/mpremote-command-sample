//
//  Asset.m
//  MPRemoteCommandCenter
//
//  Created by Đặng Văn Trường on 10/21/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "Asset.h"

@implementation Asset

- (instancetype)initWithName:(NSString *)assetName URL:(AVURLAsset *)urlAsset {
    self = [super init];
    if (self != nil) {
        self.assetName = assetName;
        self.urlAsset = urlAsset;
    }
    return self;
}

+ (NSString *)nameKey {
    return @"AssetName";
}

@end
