//
//  AppMenuItem.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "AppMenuItem.h"

@implementation AppMenuItem

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubmenuItems];
    }
    
    return self;
}

- (void)setupSubmenuItems {
    NSMenu *submenu = [NSMenu new];
    
    NSMenuItem *aboutItem = [[NSMenuItem alloc] initWithTitle:@"About..."
                                                       action:@selector(orderFrontStandardAboutPanel:)
                                                keyEquivalent:@""];
    
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                                      action:@selector(terminate:)
                                               keyEquivalent:@"q"];
    
    submenu.itemArray = @[
        aboutItem,
        [NSMenuItem separatorItem],
        quitItem
    ];
    
    [aboutItem release];
    
    self.submenu = submenu;
    [submenu release];
}

@end
