//
//  MTHostGameViewController.h
//  Four in a Row
//
//  Created by Bart Jacobs on 11/04/13.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;
@protocol MTHostGameViewControllerDelegate;

@interface MTHostGameViewController : UIViewController

@property (weak, nonatomic) id<MTHostGameViewControllerDelegate> delegate;

@end

@protocol MTHostGameViewControllerDelegate <NSObject>
- (void)controller:(MTHostGameViewController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controllerDidCancelHosting:(MTHostGameViewController *)controller;
@end
