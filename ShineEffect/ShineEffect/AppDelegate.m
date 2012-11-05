//
//  AppDelegate.m
//  ShineEffect
//
//  Created by Xu Jun on 11/5/12.
//  Copyright (c) 2012 Xu Jun. All rights reserved.
//

#import "AppDelegate.h"
#import "NSObject+ShineEffect.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)onTest:(id)sender
{
    //[self.imageView shineWithRepeatCount:999999];
    [self.imageView shineWithRepeatCount:999999 orientation:ShineUpToDown];
}

@end
