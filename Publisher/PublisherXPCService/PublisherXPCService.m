//
//  PublisherXPCService.m
//  PublisherXPCService
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "PublisherXPCService.h"
#import "XPCServiceName.h"
#import "CoreDataXPCProtocol.h"
#import "NSXPCInterface+CoreDataXPCInterface.h"

@interface PublisherXPCService () <CoreDataXPCProtocol>
@property (retain) NSXPCConnection *helperConnection; // only accessed by operations on self.queue
@property (retain) NSOperationQueue *queue;
@end

@implementation PublisherXPCService

- (instancetype)init {
    if (self = [super init]) {
        [self setupQueue];
        [self setupHelperConnection];
    }
    
    return self;
}

- (void)dealloc {
    [_helperConnection invalidate];
    [_helperConnection release];
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
        [helperConnection release];
    }];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithCoreDataXPC];
    
    newConnection.exportedInterface = exportedInterface;
    newConnection.exportedObject = self;
    
    [newConnection activate];
    
    return YES;
}

- (void)input_objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes {
    [self.queue addBarrierBlock:^{
        id<CoreDataXPCProtocol> remoteObject = [self.helperConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
            if (error.code != 4097) {
                [NSException raise:NSInternalInconsistencyException format:@"%@", error];
            }
        }];
        
        [remoteObject input_objectsDidChange:changes];
    }];
}

- (void)output_objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes {
    
}

- (void)ready {
    
}

@end
