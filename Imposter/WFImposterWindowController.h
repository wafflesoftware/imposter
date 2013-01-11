//
//  WFImposterWindowController.h
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "WFImposterAssembler.h"

@class WFImposterContact;

@interface WFImposterWindowController : NSWindowController <WFImposterAssemblerDelegate>
@property (weak) IBOutlet WebView *webView;
@property (strong) IBOutlet WFImposterAssembler *assembler;

@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSTextField *countup;

@property (readonly) NSArray *selectableContacts;
@property (readonly) BOOL ready;

@property WFImposterContact *selectedContact;
@property NSNumber *chainLength;
@property NSNumber *wordCount;
- (void)start;
@end
