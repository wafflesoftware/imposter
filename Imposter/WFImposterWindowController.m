//
//  WFImposterWindowController.m
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "WFImposterAssembler.h"
#import "WFImposterWindowController.h"
#import "Adium.h"

@interface WFImposterWindowController ()
@property (readwrite) BOOL ready;
@property (readwrite) NSArray *selectableContacts;
@end

@interface WFImposterContact : NSObject
@property NSString *username;
@property NSString *displayName;
@end

@implementation WFImposterContact
+ (instancetype)contactWithUsername:(NSString *)username {
    WFImposterContact *c = [[WFImposterContact alloc] init];
    AdiumApplication *adiumApplication = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];
    NSArray *contacts = [(SBElementArray *)[adiumApplication.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", username]] get];
    NSString *displayName = username;
    if (contacts.count == 1) {
        AdiumContact *contact = contacts[0];
        displayName = contact.displayName;
    }
    c.username = username;
    c.displayName = displayName;
    return c;
}


- (NSString *)compositeName {
    return [NSString stringWithFormat:@"%@ — %@", self.displayName, self.username];
}

- (NSComparisonResult)compare:(WFImposterContact *)result {
    return [self.displayName caseInsensitiveCompare:result.displayName];
}
@end

@implementation WFImposterWindowController
-(void)assemblerReady:(WFImposterAssembler *)assembler {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.spinner stopAnimation:nil];
    [self.spinner setHidden:YES];
    [self.countup setHidden:YES];
    self.ready = YES;
    NSMutableArray *allUsers = [NSMutableArray array];
    for (NSString *username in assembler.usernames) {
        WFImposterContact *contact = [WFImposterContact contactWithUsername:username];
        [allUsers addObject:contact];
    }
    self.selectableContacts = [allUsers sortedArrayUsingSelector:@selector(compare:)];
    });
}

- (void)assembler:(WFImposterAssembler *)assembler progress:(NSUInteger)chatCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.countup setStringValue:[NSNumber numberWithUnsignedInteger:chatCount].description];
    });
}

static NSString *kvoContext = @"gdjskggj";

- (NSString *)displayNameForUsername:(NSString *)username {
    AdiumApplication *adiumApplication = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];
    NSArray *contacts = [(SBElementArray *)[adiumApplication.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", username]] get];
    if (contacts.count == 1) {
        AdiumContact *contact = contacts[0];
        return contact.displayName;
    }
    return username;
}

- (void)assembleNewThing {
    NSString *x = [self.assembler makeUpForUsername:self.selectedContact.username chainLength:self.chainLength.unsignedIntegerValue wordCount:self.wordCount.unsignedIntegerValue];
    [[self.webView mainFrame] loadData:[x dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:[NSURL fileURLWithPath:@"/"]];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kvoContext) {
        [self performSelector:@selector(assembleNewThing) withObject:nil afterDelay:0.01];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)start {
    
    WebPreferences *prefs = [[WebPreferences alloc] initWithIdentifier:@"WFImposter"];

    [prefs setFixedFontFamily:@"Cochin"];
    [prefs setDefaultFixedFontSize:19];

    [self.webView setPreferences:prefs];
    
    self.chainLength = @3;
    self.wordCount = @200;
    
    [self addObserver:self forKeyPath:@"selectedContact" options:NSKeyValueObservingOptionNew context:(void *)&kvoContext];
    [self addObserver:self forKeyPath:@"chainLength" options:NSKeyValueObservingOptionNew context:(void *)&kvoContext];
    [self addObserver:self forKeyPath:@"wordCount" options:NSKeyValueObservingOptionNew context:(void *)&kvoContext];
    
    [self.spinner startAnimation:nil];
    
    self.assembler.delegate = self;
    [self.assembler startAssembling];
    [self showWindow:nil];
}

@end
