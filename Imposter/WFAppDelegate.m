//
//  WFAppDelegate.m
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "WFAppDelegate.h"
#import "WFMarkov.h"
#import "Adium.h"

#import "WFImposterWindowController.h"

@implementation WFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    AdiumApplication *adiumApplication = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];
    if (adiumApplication == nil) {
        [self.noSupportWindow makeKeyAndOrderFront:self];
    } else {
        [self.imposterWindowController start];
    }
}


@end
