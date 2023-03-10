//
//  EditMenuItem.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "EditMenuItem.h"

@implementation EditMenuItem

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubmenuItems];
    }
    
    return self;
}

- (void)setupSubmenuItems {
    NSMenu *submenu = [[NSMenu alloc] initWithTitle:@"Edit"];
    
    NSMenuItem *undoItem = [[NSMenuItem alloc] initWithTitle:@"Undo"
                                                      action:NSSelectorFromString(@"undo:")
                                               keyEquivalent:@"z"];
    
    NSMenuItem *redoItem = [[NSMenuItem alloc] initWithTitle:@"Redo"
                                                      action:NSSelectorFromString(@"redo:")
                                               keyEquivalent:@"z"];
    
    NSMenuItem *cutItem = [[NSMenuItem alloc] initWithTitle:@"Cut"
                                                     action:@selector(cut:)
                                              keyEquivalent:@"x"];
    
    NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"Copy"
                                                      action:@selector(copy:)
                                               keyEquivalent:@"c"];
    
    NSMenuItem *pasteItem = [[NSMenuItem alloc] initWithTitle:@"Paste"
                                                       action:@selector(paste:)
                                                keyEquivalent:@"v"];
    
    NSMenuItem *deleteItem = [[NSMenuItem alloc] initWithTitle:@"Delete"
                                                        action:@selector(delete:)
                                                 keyEquivalent:@""];
    
    NSMenuItem *selectAllItem = [[NSMenuItem alloc] initWithTitle:@"Select All"
                                                           action:@selector(selectAll:)
                                                    keyEquivalent:@"a"];
    
    redoItem.keyEquivalentModifierMask = NSEventModifierFlagShift | NSEventModifierFlagCommand;
    
    submenu.itemArray = @[
        undoItem,
        redoItem,
        cutItem,
        copyItem,
        pasteItem,
        deleteItem,
        selectAllItem
    ];
    
    [undoItem release];
    [redoItem release];
    [cutItem release];
    [copyItem release];
    [pasteItem release];
    [deleteItem release];
    [selectAllItem release];
    
    self.submenu = submenu;
    [submenu release];
}

@end
