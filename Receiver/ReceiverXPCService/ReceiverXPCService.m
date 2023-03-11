//
//  ReceiverXPCService.m
//  ReceiverXPCService
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "ReceiverXPCService.h"
#import "CoreDataXPCProtocol.h"
#import "XPCServiceName.h"
#import "NSXPCInterface+CoreDataXPCInterface.h"

@interface ReceiverXPCService () <CoreDataXPCProtocol>
@property (retain) NSXPCConnection *helperConnection; // only accessed by operations on self.queue
@property (retain) NSMutableSet<NSXPCConnection *> *connections;
@property (retain) NSOperationQueue *queue;
@end

@implementation ReceiverXPCService

- (instancetype)init {
    if (self = [super init]) {
        [self setupQueue];
        [self setupConnections];
        [self setupHelperConnection];
    }
    
    return self;
}

- (void)dealloc {
    [_helperConnection invalidate];
    [_helperConnection release];
    
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
    queue.qualityOfService = NSQualityOfServiceUtility;
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

- (void)setupHelperConnection {
    [self.queue addBarrierBlock:^{
        NSXPCConnection *helperConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperXPCMachServiceName options:NSXPCConnectionPrivileged];
        
        NSXPCInterface *interface = [NSXPCInterface interfaceWithCoreDataXPC];
        
        helperConnection.exportedInterface = interface;
        helperConnection.exportedObject = self;
        helperConnection.remoteObjectInterface = interface;
        
        helperConnection.invalidationHandler = ^{
            [self.queue addBarrierBlock:^{
                // Release objects captured by block.
                helperConnection.invalidationHandler = nil;
                static NSUInteger retryCount = 0;
                
                retryCount += 1;
                NSLog(@"Invaldated XPC Connection, retrying... (%ld)", retryCount);
                
                if (retryCount == 10) {
                    [NSException raise:NSInconsistentArchiveException format:@"Recheaded maximum count of retry."];
                }
                
                [self setupHelperConnection];
            }];
        };
        
        self.helperConnection = helperConnection;
        [helperConnection activate];
        
        id<CoreDataXPCProtocol> remoteObjectProxy = [helperConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
            if (error.code != 4097) {
                [NSException raise:NSInternalInconsistencyException format:@"%@", error];
            }
        }];
        
        [remoteObjectProxy ready];
        
        [helperConnection release];
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
    
}

- (void)output_objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes {
    [self.queue addBarrierBlock:^{
        [self.connections enumerateObjectsUsingBlock:^(NSXPCConnection * _Nonnull obj, BOOL * _Nonnull stop) {
            id<CoreDataXPCProtocol> remoteObjectProxy = [obj remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
                if (error.code != 4097) {
                    [NSException raise:NSInternalInconsistencyException format:@"%@", error];
                }
            }];
            
            if ([remoteObjectProxy respondsToSelector:@selector(output_objectsDidChange:)]) {
                [remoteObjectProxy output_objectsDidChange:changes];
            }
        }];
    }];
}

- (void)ready {
    
}

@end
