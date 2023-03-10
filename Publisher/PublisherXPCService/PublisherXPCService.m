//
//  PublisherXPCService.m
//  PublisherXPCService
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "PublisherXPCService.h"

@implementation PublisherXPCService

- (void)objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes withReply:(void (^)(void))reply {
    NSLog(@"%@", changes);
    reply();
}

@end
