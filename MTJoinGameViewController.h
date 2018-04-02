//
//  MTJoinGameViewController.h
//  Four in a Row
//
//  Created by Bart Jacobs on 11/04/13.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;
@protocol MTJoinGameViewControllerDelegate;

@interface MTJoinGameViewController : UITableViewController

@property (weak, nonatomic) id<MTJoinGameViewControllerDelegate> delegate;

@end

@protocol MTJoinGameViewControllerDelegate <NSObject>
- (void)controller:(MTJoinGameViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controllerDidCancelJoining:(MTJoinGameViewController *)controller;
@end
