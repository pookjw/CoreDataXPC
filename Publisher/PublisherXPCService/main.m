//
//  main.m
//  PublisherXPCService
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>
#import "PublisherXPCService.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

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

int main(int argc, const char *argv[]) {
    ServiceDelegate *delegate = [ServiceDelegate new];
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = delegate;
    //    [delegate release];
    [listener activate];
    return EXIT_FAILURE;
}
