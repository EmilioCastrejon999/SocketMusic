//
//  MTServerViewController.m
//  SocketMusic
//
//  Created by Emilio Castrejon Guerrero on 3/7/18.
//  Copyright © 2018 Emilio Castrejon Guerrero. All rights reserved.
//

#import "MTServerViewController.h"

#import "MTGameController.h"
#import "MTHostGameViewController.h"
#import "MTJoinGameViewController.h"

@interface MTServerViewController ()<MTGameControllerDelegate, MTHostGameViewControllerDelegate, MTJoinGameViewControllerDelegate>

@property (strong, nonatomic) MTGameController *gameController;

@end

@implementation MTServerViewController


#pragma mark -
#pragma mark View Life Cycle
- (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 
	 musicPlayer = [MPMusicPlayerController systemMusicPlayer];
	 [self registerMediaPlayerNotifications];
	 [self startGameWithSocket: self.socket];
	 
	 
}

- (void)controller:(MTGameController *)controller didAddTxt:(NSString *)txt {
					}

- (void) registerMediaPlayerNotifications
{
	 NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	 
	 [notificationCenter addObserver: self
									selector: @selector (handle_NowPlayingItemChanged:)
										 name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
									  object: musicPlayer];
	 
	 [notificationCenter addObserver: self
									selector: @selector (handle_PlaybackStateChanged:)
										 name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
									  object: musicPlayer];
	 
	 [notificationCenter addObserver: self
									selector: @selector (handle_VolumeChanged:)
										 name: MPMusicPlayerControllerVolumeDidChangeNotification
									  object: musicPlayer];
	 
	 [musicPlayer beginGeneratingPlaybackNotifications];
}


- (void) handle_NowPlayingItemChanged: (id) notification
{
	 if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {

	 enviar = [NSString stringWithFormat:@"Play,%@,%.5f",musicPlayer.nowPlayingItem.title,musicPlayer.currentPlaybackTime];
	 
	 [self.gameController addTxt: enviar];
	 }
}

- (void) handle_PlaybackStateChanged: (id) notification
{
	 
}

- (void) handle_VolumeChanged: (id) notification
{
	 [self.gameController addTxt:[NSString stringWithFormat:@"%.2f", musicPlayer.volume]];
}




#pragma mark -
#pragma mark Game Controller Delegate Methods
- (void)controllerDidDisconnect:(MTGameController *)controller {
	 NSLog(@"%s", __PRETTY_FUNCTION__);
	 
	 // End Game
	 [self endGame];
}




- (IBAction)disconnect:(id)sender {
	 [self endGame];
}



#pragma mark -
#pragma mark Helper Methods
- (void)startGameWithSocket:(GCDAsyncSocket *)socket {
	 
	 // Initialize Game Controller
	 self.gameController = [[MTGameController alloc] initWithSocket:socket];
	 
	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"se inicio la concceion con el socket"
	 message:[NSString stringWithFormat:@"%@",socket]
	 delegate:self
	 cancelButtonTitle:@"Continuar"
	 otherButtonTitles: nil];
	 [alert show];
	 
	 // Configure Game Controller
	 [self.gameController setDelegate:self];
	 
}

- (void)endGame {
	 // Clean Up
	 
	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Se perdio la coneccion con el socket"
																	 message:@"reinicie la conceccion"
																	delegate:self
														cancelButtonTitle:@"Continuar"
														otherButtonTitles: nil];
	 [alert show];
	 
	 [self.gameController setDelegate:nil];
	 [self setGameController:nil];
	 
	 
	 [self.txtenviar setHidden:YES];}



- (void)playPause {
	 if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
		  [musicPlayer pause];
		  
	 } else {
		  
		  [musicPlayer play];
	 }
	 
	 [self.gameController addTxt:@"PlayPause"];
}


//ENVIA !!

- (IBAction)enviar:(id)sender {
	 
	 [self.gameController addTxt: _txtenviar.text];
	 
}

-(IBAction)PlayDuplicate:(id)sender{
	 
	 enviar = [NSString stringWithFormat:@"Play,%@,%.5f",musicPlayer.nowPlayingItem.title,musicPlayer.currentPlaybackTime];
	 
	 [self.gameController addTxt: enviar];
}

- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
	 
	 NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
	 
	 //allow socket to operate when the iOS application has been backgrounded
	 [self.socket performBlock:^{
		  [self.socket enableBackgroundingOnSocket];
	 }];
}


-(IBAction)Play:(id)sender{
	 [self playPause];
}

-(IBAction)Pause:(id)sender{
	 [self playPause];
}

-(IBAction)Previous:(id)sender{
	 [musicPlayer skipToPreviousItem];
}

-(IBAction)Next:(id)sender{
	 [musicPlayer skipToNextItem];
}


@end
