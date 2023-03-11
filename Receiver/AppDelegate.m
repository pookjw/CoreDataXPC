//
//  AppDelegate.m
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "AppDelegate.h"
#import "ReceiverXPCManager.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [ReceiverXPCManager.sharedInstance run];
}

@end
