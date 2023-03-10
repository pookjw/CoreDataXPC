//
//  ServiceDelegate.m
//  CoreDataXPC
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "ServiceDelegate.h"
#import "PublisherXPCService.h"

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(PublisherXPCServiceProtocol)];
    [exportedInterface setClasses:[NSSet setWithArray:@[NSDictionary.class, NSArray.class, NSString.class, NSURL.class]]
                      forSelector:@selector(objectsDidChange:withReply:)
                    argumentIndex:0
                          ofReply:NO];
    
    newConnection.exportedInterface = exportedInterface;
    
    PublisherXPCService *exportedObject = [PublisherXPCService new];
    newConnection.exportedObject = exportedObject;
    [exportedObject release];
    
    [newConnection activate];
    
    return YES;
}

@end
