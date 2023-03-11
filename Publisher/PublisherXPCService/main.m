//
//  main.m
//  PublisherXPCService
//
//  Created by Jinwoo Kim on 3/11/23.
//

#import <Foundation/Foundation.h>
#import "PublisherXPCService.h"

int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    PublisherXPCService *service = [PublisherXPCService new];
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = service;
    [listener activate];
    [service release];
    
    [pool release];
    return EXIT_FAILURE;
}
