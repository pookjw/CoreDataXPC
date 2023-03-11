//
//  AppDelegate.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BaseMenu.h"
#import "PublisherXPCManager.h"

@interface AppDelegate ()
@property (retain) NSWindow *window;
@end

@implementation AppDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [PublisherXPCManager.sharedInstance run];
    
    NSWindow *window = [NSWindow new];
    
    window.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
    window.movableByWindowBackground = YES;
    window.contentMinSize = NSMakeSize(400.f, 200.f);
    window.releasedWhenClosed = NO;
    window.titlebarAppearsTransparent = YES;
    window.title = @"Publisher";
    
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

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

@end
