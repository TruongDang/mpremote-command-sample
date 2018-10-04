//
//  Asset.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "Asset.h"

@implementation Asset
-(instancetype)init {
    self = [super init];
    if (self != nil) {
        nameKey = @"AssetName";
    }
    return self;
}

@end
