//
//  HelperDelegate.m
//  CoreDataXPCHelper
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "HelperDelegate.h"
#import "CoreDataXPCProtocol.h"
#import "NSXPCInterface+CoreDataXPCInterface.h"

@interface HelperDelegate () <CoreDataXPCProtocol>
@property (retain) NSMutableSet<NSXPCConnection *> *connections; // only accessed by operations on self.queue
@property (retain) NSOperationQueue *queue;
@end

@implementation HelperDelegate

- (instancetype)init {
    if (self = [super init]) {
        [self setupQueue];
        [self setupConnections];
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

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSQualityOfServiceBackground;
    self.queue = queue;
    [queue release];
}

- (void)setupConnections {
    [self.queue addBarrierBlock:^{
        NSMutableSet<NSXPCConnection *> *connections = [NSMutableSet<NSXPCConnection *> new];
        self.connections = connections;
        [connections release];
    }];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSXPCInterface *interface = [NSXPCInterface interfaceWithCoreDataXPC];
    
    newConnection.exportedInterface = interface;
    newConnection.exportedObject = self;
    newConnection.remoteObjectInterface = interface;
    
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

- (void)input_objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes {
    [self.queue addBarrierBlock:^{
        [self.connections enumerateObjectsUsingBlock:^(NSXPCConnection * _Nonnull obj, BOOL * _Nonnull stop) {
            id<CoreDataXPCProtocol> remoteObjectProxy = [obj remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
                if (error.code != 4097) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@", error];
                }
            }];
            
            [remoteObjectProxy output_objectsDidChange:changes];
        }];
    }];
}

- (void)output_objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes {
    
}

- (void)ready {
    
}

@end
