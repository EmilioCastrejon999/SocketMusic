//
//  MTServerViewController.h
//  SocketMusic
//
//  Created by Emilio Castrejon Guerrero on 3/7/18.
//  Copyright © 2018 Emilio Castrejon Guerrero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MTServerViewController : UIViewController<MPMediaPickerControllerDelegate>
{
	 NSTimer * timer;
	 NSString * enviar;
	 
	 MPMusicPlayerController *musicPlayer;
	 
}

@property (weak, nonatomic) IBOutlet UITextField *txtenviar;

@property (strong, nonatomic) GCDAsyncSocket *socket;


@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;


@end
