//
//  BaseMenu.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "BaseMenu.h"
#import "AppMenuItem.h"
#import "EditMenuItem.h"

@implementation BaseMenu

- (instancetype)init {
    if (self = [super init]) {
        [self setupAppMenuItem];
    }
    
    return self;
}

- (void)setupAppMenuItem {
    AppMenuItem *appMenuItem = [AppMenuItem new];
    [self addItem:appMenuItem];
    [appMenuItem release];
    
    EditMenuItem *editMenuItem = [EditMenuItem new];
    [self addItem:editMenuItem];
    [editMenuItem release];
}

@end
