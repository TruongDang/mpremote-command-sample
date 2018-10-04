//
//  RemoteCommandDataSource.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "RemoteCommandDataSource.h"

@implementation RemoteCommandDataSource

-(instancetype)initWithRemoteCommandManager:(RemoteCommandManager *)remoteCommandManager {
    self = [super init];
    if (self != nil) {
        self->remoteCommandManager = remoteCommandManager;
    }
    return self;
}

@end
