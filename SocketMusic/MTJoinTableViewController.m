//
//  MTJoinTableViewController.m
//  SocketMusic
//
//  Created by Emilio Castrejon Guerrero on 15/11/16.
//  Copyright © 2016 Emilio Castrejon Guerrero. All rights reserved.
//

#import "MTJoinTableViewController.h"
#import "MTPacket.h"

#import "MTViewController.h"
#import "MTServerViewController.h"

@interface MTJoinTableViewController () <NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;

@end

@implementation MTJoinTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	 
	 [self startBrowsing];
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	 return self.services ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	 return [self.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];

	 
	 // Fetch Service
	 NSNetService *service = [self.services objectAtIndex:[indexPath row]];
	 
	 // Configure Cell
	 [cell.textLabel setText:[service name]];
	 
	 return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 [tableView deselectRowAtIndexPath:indexPath animated:YES];
	 
	 // Fetch Service
	 NSNetService *service = [self.services objectAtIndex:[indexPath row]];
	 
	 // Resolve Service
	 [service setDelegate:self];
	 [service resolveWithTimeout:30.0];
}

#pragma mark -
#pragma mark Net Service Browser Delegate Methods
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
	 [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo {
	 [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
	 // Update Services
	 [self.services addObject:service];
	 
	 if(!moreComing) {
		  // Sort Services
		  [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
		  
		  // Update Table View
		  [self.tableView reloadData];
	 }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
	 // Update Services
	 [self.services removeObject:service];
	 
	 if(!moreComing) {
		  // Update Table View
		  [self.tableView reloadData];
	 }
}

#pragma mark -
#pragma mark Net Service Delegate Methods
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
	 [service setDelegate:nil];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	 // Connect With Service
	 if ([self connectWithService:service]) {
		  NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
	 } else {
		  NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
	 }
}

#pragma mark -
#pragma mark Async Socket Delegate Mehods
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
	 NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
	 
	 // Notify Delegate
	 [self.delegate controller:self didJoinGameOnSocket:socket];
	 
	 // Stop Browsing
	 [self stopBrowsing];

	 [socket performBlock:^{
		  [socket enableBackgroundingOnSocket];
	 }];
	 
	 MTViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"Client"];
	 view.socket = socket;

	 [self.navigationController pushViewController:view animated:YES];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
	 NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
	 
	 [socket setDelegate:nil];
	 [self setSocket:nil];
}

#pragma mark -
#pragma mark Helper Methods
- (void)startBrowsing {
	 if (self.services) {
		  [self.services removeAllObjects];
	 } else {
		  self.services = [[NSMutableArray alloc] init];
	 }
	 
	 // Initialize Service Browser
	 self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
	 
	 // Configure Service Browser
	 [self.serviceBrowser setDelegate:self];
	 [self.serviceBrowser searchForServicesOfType:@"_fourinarow._tcp." inDomain:@"local."];
}

- (void)stopBrowsing {
	 if (self.serviceBrowser) {
		  [self.serviceBrowser stop];
		  [self.serviceBrowser setDelegate:nil];
		  [self setServiceBrowser:nil];
	 }
}

- (BOOL)connectWithService:(NSNetService *)service {
	 BOOL _isConnected = NO;
	 
	 // Copy Service Addresses
	 NSArray *addresses = [[service addresses] mutableCopy];
	 
	 if (!self.socket || ![self.socket isConnected]) {
		  // Initialize Socket
		  self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		  
		  // Connect
		  while (!_isConnected && [addresses count]) {
				NSData *address = [addresses objectAtIndex:0];
				
				NSError *error = nil;
				if ([self.socket connectToAddress:address error:&error]) {
					 _isConnected = YES;
					 
				} else if (error) {
					 NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
				}
		  }
		  
	 } else {
		  _isConnected = [self.socket isConnected];
	 }
	 
	 return _isConnected;
}














- (IBAction)Host:(UIBarButtonItem *)sender {

	 if ([sender.title isEqualToString:@"Host"]) {
		  [self startBroadcast];
		  [self.TBV setUserInteractionEnabled:NO];
		  sender.title = @"Cancel Host";
		  
		  [self.delegate controllerDidCancelJoining:self];
		  [self stopBrowsing];
		  
		  
		  self.services = [NSMutableArray new];
	 }
	 else{
		  [self.delegate controllerDidCancelHosting:self];
		  [self endBroadcast];
		  [self startBrowsing];
		  [self.TBV setUserInteractionEnabled:YES];
		  sender.title = @"Host";
	 }
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
	 
	 [newSocket performBlock:^{
		  [newSocket enableBackgroundingOnSocket];
	 }];
	 
	 // Dismiss View Controller
	 MTServerViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"Server"];
	 
	 view.socket = newSocket;
	 [self.navigationController pushViewController:view animated:YES];
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
