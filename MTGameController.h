//
//  MTGameController.h
//  Four in a Row
//
//  Created by Bart Jacobs on 20/04/13.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@protocol MTGameControllerDelegate;

@interface MTGameController : NSObject

@property (weak, nonatomic) id <MTGameControllerDelegate> delegate;

#pragma mark -
#pragma mark Initialization
- (id)initWithSocket:(GCDAsyncSocket *)socket;

#pragma mark -

//ACCIONES QUE VIENEN DEL PCKETE

#pragma mark Public Instance Methods
- (void)startNewGame;
- (void)addTxt:(NSString*)txt;

@end

@protocol MTGameControllerDelegate <NSObject>
- (void)controller:(MTGameController *)controller didAddTxt:(NSString*)txt;
- (void)controllerDidStartNewGame:(MTGameController *)controller;
- (void)controllerDidDisconnect:(MTGameController *)controller;
@end
