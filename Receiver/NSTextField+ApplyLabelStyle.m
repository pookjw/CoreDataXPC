//
//  NSTextField+ApplyLabelStyle.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "NSTextField+ApplyLabelStyle.h"

@implementation NSTextField (ApplyLabelStyle)

- (void)applyLabelStyle {
    self.editable = NO;
    self.selectable = NO;
    self.bezeled = NO;
    self.preferredMaxLayoutWidth = 0.f;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.drawsBackground = NO;
}

@end
