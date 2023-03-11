//
//  ReceiverXPCManager.m
//  Receiver
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "ReceiverXPCManager.h"
#import "DataManager.h"
#import "CoreDataXPCProtocol.h"
#import "XPCServiceName.h"
#import "NSXPCInterface+CoreDataXPCInterface.h"

@interface ReceiverXPCManager () <CoreDataXPCProtocol>
@property (retain) DataManager *dataManager;
@property (retain) NSOperationQueue *queue;
@property (retain) NSXPCConnection *serviceConnection;
@end

@implementation ReceiverXPCManager

+ (ReceiverXPCManager *)sharedInstance {
    static ReceiverXPCManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [ReceiverXPCManager new];
    });
    
    return sharedInstance;
}

- (void)dealloc {
    [_dataManager release];
    [_serviceConnection invalidate];
    [_serviceConnection release];
    [_queue cancelAllOperations];
    [_queue release];
    [super dealloc];
}

- (void)run {
    [self setupQueue];
    [self setupServiceConnection];
    [self setupDataManger];
}

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    queue.qualityOfService = NSQualityOfServiceUtility;
    self.queue = queue;
    [queue release];
}

- (void)setupServiceConnection {
    [self.queue addBarrierBlock:^{
        NSXPCConnection *serviceConnection = [[NSXPCConnection alloc] initWithServiceName:kReceiverXPCServiceName];
        
        NSXPCInterface *interface = [NSXPCInterface interfaceWithCoreDataXPC];
        
        serviceConnection.remoteObjectInterface = interface;
        serviceConnection.exportedInterface = interface;
        serviceConnection.exportedObject = self;
        
        serviceConnection.invalidationHandler = ^{
            [self.queue addBarrierBlock:^{
                // Release objects captured by block.
                serviceConnection.invalidationHandler = nil;
                static NSUInteger retryCount = 0;
                
                retryCount += 1;
                NSLog(@"Invaldated XPC Connection, retrying... (%ld)", retryCount);
                
                if (retryCount == 10) {
                    [NSException raise:NSInconsistentArchiveException format:@"Recheaded maximum count of retry."];
                }
                
                [self setupServiceConnection];
            }];
        };
        
        self.serviceConnection = serviceConnection;
        [serviceConnection activate];
        
        id<CoreDataXPCProtocol> remoteObjectProxy = [serviceConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
            if (error.code != 4097) {
                [NSException raise:NSInternalInconsistencyException format:@"%@", error];
            }
        }];
        
        [remoteObjectProxy ready];
        [serviceConnection release];
    }];
}

- (void)setupDataManger {
    DataManager *dataManager = DataManager.sharedInstance;
    self.dataManager = dataManager;
}

- (void)input_objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes {
    
}

- (void)output_objectsDidChange:(NSDictionary<NSString *,NSURL *> *)changes {
    NSLog(@"%@", changes);
}

- (void)ready {
    
}

@end
