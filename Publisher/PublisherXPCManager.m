//
//  PublisherXPCManager.m
//  Publisher
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import "PublisherXPCManager.h"
#import "DataManager.h"
#import "DataManagedObject.h"
#import "CoreDataXPCProtocol.h"
#import "XPCServiceName.h"
#import "NSXPCInterface+CoreDataXPCInterface.h"

@interface PublisherXPCManager ()
@property (retain) DataManager *dataManager;
@property (retain) NSOperationQueue *queue;
@property (retain) NSXPCConnection *serviceConnection;
@end

@implementation PublisherXPCManager

+ (PublisherXPCManager *)sharedInstance {
    static PublisherXPCManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [PublisherXPCManager new];
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
    [self addObserver];
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
        NSXPCConnection *serviceConnection = [[NSXPCConnection alloc] initWithServiceName:kPublisherXPCServiceName];
        
        serviceConnection.remoteObjectInterface = [NSXPCInterface interfaceWithCoreDataXPC];
        
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
        [serviceConnection release];
    }];
}

- (void)setupDataManger {
    DataManager *dataManager = DataManager.sharedInstance;
    self.dataManager = dataManager;
}

- (void)addObserver {
    [self.dataManager.queue addBarrierBlock:^{
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(triggeredObjectsDidChangeNotification:)
                                                   name:NSManagedObjectContextObjectsDidChangeNotification
                                                 object:self.dataManager.context];
    }];
}

- (void)triggeredObjectsDidChangeNotification:(NSNotification *)notification {
    id<CoreDataXPCProtocol> remoteObjectProxy = [self.serviceConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        if (error.code != 4097) {
            [NSException raise:NSInternalInconsistencyException format:@"%@", error];
        }
    }];
    
    NSDictionary *userInfo = notification.userInfo;
    
    NSMutableDictionary *changes = [NSMutableDictionary new];
    [userInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSSet<DataManagedObject *> class]]) {
            NSMutableArray *URIRepresentations = [NSMutableArray new];
            
            [obj enumerateObjectsUsingBlock:^(DataManagedObject * _Nonnull obj, BOOL * _Nonnull stop) {
                [URIRepresentations addObject:obj.objectID.URIRepresentation];
            }];
            
            NSArray *results = [URIRepresentations copy];
            [URIRepresentations release];
            changes[key] = results;
            [results release];
        }
    }];
    
    NSDictionary *results = [changes copy];
    [changes release];
    
    [remoteObjectProxy input_objectsDidChange:results];
    [results release];
}

@end
