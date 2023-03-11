//
//  HelperDelegate.m
//  CoreDataXPCHelper
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "HelperDelegate.h"
#import "XPCHelperProtocol.h"

@interface HelperDelegate ()
@end

@implementation HelperDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XPCHelperProtocol)];
    
    [exportedInterface setClasses:[NSSet setWithArray:@[NSDictionary.class, NSArray.class, NSString.class, NSURL.class]]
                      forSelector:@selector(objectsDidChange:withReply:)
                    argumentIndex:0
                          ofReply:NO];
    
    newConnection.exportedInterface = exportedInterface;
    
    // TODO
    
    return YES;
}

@end
