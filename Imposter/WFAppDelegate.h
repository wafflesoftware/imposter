//
//  WFAppDelegate.h
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WFImposterWindowController;

@interface WFAppDelegate : NSObject <NSApplicationDelegate>
@property (assign) IBOutlet WFImposterWindowController *imposterWindowController;
@property (assign) IBOutlet NSWindow *noSupportWindow;
@end
