//
//  HelperDelegate.m
//  CoreDataXPCHelper
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "HelperDelegate.h"
#import "XPCHelperInputProtocol.h"
#import "XPCHelperOutputProtocol.h"

@interface HelperDelegate () <XPCHelperInputProtocol>
@property (retain) NSMutableSet<NSXPCConnection *> *connections; // only accessed by operations on self.queue
@property (retain) NSOperationQueue *queue;
@end

@implementation HelperDelegate

- (instancetype)init {
    if (self = [super init]) {
        [self setupConnections];
        [self setupQueue];
    }
    
    return self;
}

- (void)dealloc {
    // `-[NSXPCConnection invalidationHandler]` mutates self.connections, it will be error while running enumeration block.
    NSSet<NSXPCConnection *> *connections = [_connections copy];
    [connections enumerateObjectsUsingBlock:^(NSXPCConnection * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidate];
    }];
    [connections release];
    [_connections release];
    
    [_queue cancelAllOperations];
    [_queue release];
    
    [super dealloc];
}

- (void)setupConnections {
    NSMutableSet<NSXPCConnection *> *connections = [NSMutableSet<NSXPCConnection *> new];
    self.connections = connections;
    [connections release];
}

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSQualityOfServiceBackground;
    self.queue = queue;
    [queue release];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XPCHelperInputProtocol)];
    
    [exportedInterface setClasses:[NSSet setWithArray:@[NSDictionary.class, NSArray.class, NSString.class, NSURL.class]]
                      forSelector:@selector(input_objectsDidChange:withReply:)
                    argumentIndex:0
                          ofReply:NO];
    
    newConnection.exportedInterface = exportedInterface;
    newConnection.exportedObject = self;
    
    NSXPCInterface *remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XPCHelperOutputProtocol)];
    
    [remoteObjectInterface setClasses:[NSSet setWithArray:@[NSDictionary.class, NSArray.class, NSString.class, NSURL.class]]
                      forSelector:@selector(output_objectsDidChange:)
                    argumentIndex:0
                          ofReply:NO];
    
    newConnection.remoteObjectInterface = remoteObjectInterface;
    
    newConnection.invalidationHandler = ^{
        newConnection.invalidationHandler = nil;
        
        [self.queue addBarrierBlock:^{
            [self.connections removeObject:newConnection];
        }];
    };
    
    [self.queue addBarrierBlock:^{
        [self.connections addObject:newConnection];
        [newConnection activate];
    }];
    
    return YES;
}

- (void)input_objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes withReply:(void (^)(void))reply {
    [self.queue addBarrierBlock:^{
        [self.connections enumerateObjectsUsingBlock:^(NSXPCConnection * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(XPCHelperOutputProtocol)]) {
                id<XPCHelperOutputProtocol> remoteObjectProxy = obj.remoteObjectProxy;
                [remoteObjectProxy output_objectsDidChange:changes];
            }
        }];
        
        reply();
    }];
}

@end
