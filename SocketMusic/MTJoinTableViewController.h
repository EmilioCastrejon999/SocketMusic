//
//  MTJoinTableViewController.h
//  SocketMusic
//
//  Created by Emilio Castrejon Guerrero on 15/11/16.
//  Copyright © 2016 Emilio Castrejon Guerrero. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GCDAsyncSocket;
@protocol MTJoinTableViewControllerDelegate;

@interface MTJoinTableViewController : UITableViewController

@property (weak, nonatomic) id<MTJoinTableViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *TBV;

@end

@protocol MTJoinTableViewControllerDelegate <NSObject>
- (void)controller:(MTJoinTableViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controllerDidCancelJoining:(MTJoinTableViewController *)controller;


- (void)controller:(MTJoinTableViewController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controllerDidCancelHosting:(MTJoinTableViewController *)controller;
@end

