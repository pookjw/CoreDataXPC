//
//  AppDelegate.m
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BaseMenu.h"
#import "ReceiverXPCManager.h"

@interface AppDelegate ()
@property (retain) NSWindow *window;
@end

@implementation AppDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [ReceiverXPCManager.sharedInstance run];
    
    NSWindow *window = [NSWindow new];
    
    window.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
    window.movableByWindowBackground = YES;
    window.contentMinSize = NSMakeSize(400.f, 600.f);
    window.releasedWhenClosed = NO;
    window.titlebarAppearsTransparent = YES;
    window.title = @"Receiver";
    
    ViewController *contentViewController = [ViewController new];
    window.contentViewController = contentViewController;
    [contentViewController release];
    
    [window makeKeyAndOrderFront:self];
    
    self.window = window;
    [window release];
    
    BaseMenu *mainMenu = [BaseMenu new];
    NSApp.mainMenu = mainMenu;
    [mainMenu release];
}

@end
