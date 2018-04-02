//
//  MTViewController.h
//  Four in a Row
//
//  Created by Bart Jacobs on 11/04/13.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MTViewController : UIViewController<MPMediaPickerControllerDelegate>

//
{
    NSTimer * timer;
    NSString * enviar;
	 
	 MPMusicPlayerController *musicPlayer;

}

@property (weak, nonatomic) IBOutlet UILabel *txtrecibir;

@property (strong, nonatomic) GCDAsyncSocket *socket;


@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;


@end
