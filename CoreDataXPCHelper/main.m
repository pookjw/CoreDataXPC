//
//  main.m
//  CoreDataXPCHelper
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>
#import "HelperDelegate.h"

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    HelperDelegate *delegate = [HelperDelegate new];
    NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:@"com.pookjw.CoreDataXPC.Helper"];
    listener.delegate = delegate;
    [listener activate];
    [delegate release];
    [listener release];
    
    [pool release];
    return EXIT_FAILURE;
}
