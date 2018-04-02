//
//  MTHostGameViewController.m
//  Four in a Row
//
//  Created by Bart Jacobs on 11/04/13.
//  Copyright (c) 2013 Mobile Tuts. All rights reserved.
//

#import "MTHostGameViewController.h"

#import "MTPacket.h"

@interface MTHostGameViewController () <NSNetServiceDelegate, GCDAsyncSocketDelegate>

@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

@implementation MTHostGameViewController


#pragma mark -
#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup View
    [self setupView];
    
    // Start Broadcast
    [self startBroadcast];
}



#pragma mark -
#pragma mark Net Service Delegate Methods
- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
}

- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [service domain], [service type], [service name], errorDict);
}

#pragma mark -
#pragma mark Async Socket Delegate Methods

- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
    // Notify Delegate
    [self.delegate controller:self didHostGameOnSocket:newSocket];
    
    // End Broadcast
    [self endBroadcast];
    
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.socket == socket) {
        [self.socket setDelegate:nil];
        [self setSocket:nil];
    }
}

#pragma mark -
#pragma mark View Methods
- (void)setupView {
    // Create Cancel Button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}


#pragma mark -
#pragma mark Actions
- (void)cancel:(id)sender {
    // Cancel Hosting Game
    [self.delegate controllerDidCancelHosting:self];
    
    // End Broadcast
    [self endBroadcast];
    
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Helper Methods
- (void)startBroadcast {
    // Initialize GCDAsyncSocket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Start Listening for Incoming Connections
    NSError *error = nil;
    if ([self.socket acceptOnPort:0 error:&error]) {
        // Initialize Service
        self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_fourinarow._tcp." name:@"" port:[self.socket localPort]];
        
        // Configure Service
        [self.service setDelegate:self];
        
        // Publish Service
        [self.service publish];
        
    } else {
        NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

- (void)endBroadcast {
    if (self.socket) {
        [self.socket setDelegate:nil delegateQueue:NULL];
        [self setSocket:nil];
    }
    
    if (self.service) {
        [self.service setDelegate:nil];
        [self setService:nil];
    }
}

@end
