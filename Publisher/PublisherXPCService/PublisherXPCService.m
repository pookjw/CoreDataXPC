//
//  PublisherXPCService.m
//  PublisherXPCService
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "PublisherXPCService.h"
#import "XPCHelperProtocol.h"

@interface PublisherXPCService ()
@property (retain) NSXPCConnection *helperConnection; // only accessed by operations on self.queue
@property (retain) NSOperationQueue *queue;
@end

@implementation PublisherXPCService

- (instancetype)init {
    if (self = [super init]) {
        [self setupQueue];
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
        NSXPCConnection *helperConnection = [[NSXPCConnection alloc] initWithMachServiceName:@"com.pookjw.CoreDataXPC.Helper" options:NSXPCConnectionPrivileged];
        NSXPCInterface *remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XPCHelperProtocol)];
        
        [remoteObjectInterface setClasses:[NSSet setWithArray:@[NSDictionary.class, NSArray.class, NSString.class, NSURL.class]]
                              forSelector:@selector(objectsDidChange:withReply:)
                            argumentIndex:0
                                  ofReply:NO];
        
        helperConnection.remoteObjectInterface = remoteObjectInterface;
        
        helperConnection.invalidationHandler = ^{
            [self.queue addBarrierBlock:^{
                // Release objects captured by block.
                helperConnection.invalidationHandler = nil;
                static NSUInteger retryCount = 0;
                
                retryCount += 1;
                NSLog(@"Invaldated XPC Connection, retrying... (%ld)", retryCount);
                
                if (retryCount == 10) {
                    assert("Recheaded maximum count of retry.");
                }
                
                [self setupHelperConnection];
            }];
        };
        
        [helperConnection activate];
        self.helperConnection = helperConnection;
        [helperConnection release];
    }];
}

- (void)objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes withReply:(void (^)(void))reply {
    [self.queue addBarrierBlock:^{
        id<XPCHelperProtocol> remoteObject = [self.helperConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
            if (error.code != 4097) {
                [NSException raise:NSInternalInconsistencyException format:@"%@", error];
            }
        }];
        
        [remoteObject objectsDidChange:changes withReply:reply];
    }];
}

@end
