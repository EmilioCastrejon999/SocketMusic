//
//  MTViewController.m
//  Four in a Row
//
//  Created by Bart Jacobs on 11/04/13.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import "MTViewController.h"

#import "MTGameController.h"
#import "MTHostGameViewController.h"
#import "MTJoinGameViewController.h"


@interface MTViewController () <MTGameControllerDelegate, MTHostGameViewControllerDelegate, MTJoinGameViewControllerDelegate>

@property (strong, nonatomic) MTGameController *gameController;


@end

@implementation MTViewController

- (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 musicPlayer = [MPMusicPlayerController systemMusicPlayer];
	 [self startGameWithSocket: self.socket];
	 
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
    

    [self.txtrecibir setHidden:YES];}


//RECIVE!!

- (void)controller:(MTGameController *)controller didAddTxt:(NSString *)txt {
	 
    _txtrecibir.text = txt;
	 
	 
	  if ([txt hasPrefix:@"Play,"]){
		  NSArray *MusicComp = [txt componentsSeparatedByString:@","];
		  
		  [self playPauseDuplicate:[MusicComp objectAtIndex:1]:[MusicComp objectAtIndex:2]];

	 }
	 
	 else if ([txt isEqualToString:@"PlayPause"]){
		  [self playPause];
	 }
				 
	 else if ([txt floatValue]){
		  [musicPlayer setVolume:[txt floatValue]];
	 }
	 else if ([txt hasPrefix:@"Time"]){
		  NSArray *ComponentsTime = [txt componentsSeparatedByString:@","];
		  [musicPlayer setCurrentPlaybackTime:[[ComponentsTime objectAtIndex:1] floatValue] ];
	 }
}
	 

- (void)playPause {
		  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
		  [musicPlayer pause];
		  
		  } else {
		  
		  [musicPlayer play];
		  }
	 
	 [self.gameController addTxt:@"PlayPause"];
}



- (void)playPauseDuplicate: (NSString *)Song :(NSString *)Time
{
	 if (Song != nil) {
		  
	 MPMediaQuery *query = [[MPMediaQuery alloc] init];
		  
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:Song forProperty:MPMediaItemPropertyTitle]];
		  
		  if ([[query items] count] != 0) {
    
		  MPMediaItem *SongItem = [[query items]objectAtIndex:0];
				
		  MPMediaItemCollection *collection = [MPMediaItemCollection collectionWithItems:[query items]];
		  
		  [musicPlayer setQueueWithItemCollection:collection];
		  [musicPlayer setNowPlayingItem: SongItem];
		  [musicPlayer setCurrentPlaybackTime: [Time floatValue]];
		  [musicPlayer prepareToPlay];
		  [musicPlayer play];
		  }
	 }
	 else{
	 if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
		  [musicPlayer pause];
		  
	 } else {
		  
		  [musicPlayer play];
	 }
	 }}


- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
	 
	 NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
	 
	 //allow socket to operate when the iOS application has been backgrounded
	 [self.socket performBlock:^{
		  [self.socket enableBackgroundingOnSocket];
	 }];
}

@end
