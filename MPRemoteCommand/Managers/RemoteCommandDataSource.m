//
//  RemoteCommandDataSource.m
//  ios-app
//
//  Created by Đặng Văn Trường on 10/4/18.
//  Copyright © 2018 Đặng Văn Trường. All rights reserved.
//

#import "RemoteCommandDataSource.h"

@implementation RemoteCommandDataSource

-(instancetype)initWithRemoteCommandManager:(RemoteCommandManager *)aRemoteCommandManager {
    self = [super init];
    if (self != nil) {
        remoteCommandManager = aRemoteCommandManager;
        [self initCommand];
    }
    return self;
}

-(void)initCommand {
    NSArray *trackChangingCommands = @[@"Next Track Command", @"Previous Track Command"];
    NSArray *skipIntervalCommands = @[@"Skip Forward Command", @"Skip Backward Command"];
    NSArray *seekCommands = @[@"Seek Forward Command", @"Seek Backward Command"];
    NSArray *feedbackCommands = @[@"Like Command", @"Dislike Command", @"Bookmark Command"];
    commands =@[@{@"Track Changing Commands":trackChangingCommands}, @{@"Skip Interval Commands":skipIntervalCommands}, @{@"Seek Commands":seekCommands}, @{@"Feedback Commands":feedbackCommands}];
}

- (NSUInteger)numberOfRemoteCommandSections {
    return 4;
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section {
    switch (section) {
        case 0:
            return 2;
            
        case 1:
            return 2;
            
        case 2:
            return 3;
            
        case 3:
            return 3;
            
        default:
            return 0;
    }
}

- (NSString *)titleForSection:(NSUInteger)section {
    if (section < [commands count]) {
        return [[(NSDictionary *)[commands objectAtIndex:section] allKeys] firstObject];
    } else {
        return @"Invalid Section";
    }
}

- (NSString *)titleForCommandAtSection:(NSUInteger)section row:(NSUInteger)row {
    if (section < [commands count]) {
        NSArray *command = [[(NSDictionary *)[commands objectAtIndex:section] allValues] firstObject];
        if (row < [command count]) {
            return [command objectAtIndex:row];
        } else {
            return @"Invalid Row";
        }
    } else {
        return @"Invalid Section";
    }
}

- (void)toggleCommandHandlerWithSection:(NSUInteger)section row:(NSUInteger)row enable:(BOOL)enable {
    if (section >= [commands count]) {
        return;
    } else {
        NSArray *command = [[(NSDictionary *)[commands objectAtIndex:section] allValues] firstObject];
        if (row >= [command count]) {
            return;
        } else {
            return;
        }
    }
    switch remoteCommand {
    case .nextTrack: remoteCommandManager.toggleNextTrackCommand(enable)
    case .previousTrack: remoteCommandManager.togglePreviousTrackCommand(enable)
    case .skipForward: remoteCommandManager.toggleSkipForwardCommand(enable, interval: 15)
    case .skipBackward: remoteCommandManager.toggleSkipBackwardCommand(enable, interval: 20)
    case .seekForward: remoteCommandManager.toggleSeekForwardCommand(enable)
    case .seekBackward: remoteCommandManager.toggleSeekBackwardCommand(enable)
    case .changePlaybackPosition: remoteCommandManager.toggleChangePlaybackPositionCommand(enable)
    case .like: remoteCommandManager.toggleLikeCommand(enable)
    case .dislike: remoteCommandManager.toggleDislikeCommand(enable)
    case .bookmark: remoteCommandManager.toggleBookmarkCommand(enable)
    }
}

@end
