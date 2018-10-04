//
//  Asset.h
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Asset : NSObject {
    
    // MARK: Types
    static NSString *nameKey;
    
    // MARK: Properties
    
    /// The name of the asset to present in the application.
    NSString *assetName;
    
    /// The `AVURLAsset` corresponding to an asset in either the application bundle or on the Internet.
    AVURLAsset *urlAsset;
}

@end
