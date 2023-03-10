//
//  PublisherXPCServiceProtocol.h
//  PublisherXPCService
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>

@protocol PublisherXPCServiceProtocol <NSObject>
- (void)objectsDidChange:(NSDictionary<NSString *, NSURL *> *)changes withReply:(void (^)(void))reply;
@end
