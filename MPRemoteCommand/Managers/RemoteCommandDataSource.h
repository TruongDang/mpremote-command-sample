//
//  RemoteCommandDataSource.h
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCommandManager.h"

@interface RemoteCommandDataSource : NSObject {
    RemoteCommandManager *remoteCommandManager;
    NSArray *commands;
}
-(instancetype)initWithRemoteCommandManager:(RemoteCommandManager *)remoteCommandManager;

@end
