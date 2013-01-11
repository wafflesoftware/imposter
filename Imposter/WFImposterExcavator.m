//
//  WFImposterExcavator.m
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "WFImposterExcavator.h"

#import <CoreServices/CoreServices.h>

@interface WFImposterExcavator ()
@property (strong) NSMetadataQuery *currentSearch;
@end

@implementation WFImposterExcavator
- (void)startLooking {
    
    if (self.currentSearch != nil) {
        [self stopLooking];
    }
    
    NSMetadataQuery *search = [[NSMetadataQuery alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidUpdate:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:search];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initalGatherComplete:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:search];
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'com.adiumx.xmllog'"];
    [search setPredicate:searchPredicate];
    
    [search setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:(id)kMDItemContentModificationDate ascending:NO]]];
    
    [search setSearchScopes:@[NSMetadataQueryUserHomeScope]];
    
    [search startQuery];
    
    self.currentSearch = search;
    
}

- (void)queryDidUpdate:(NSNotification *)noti {
    NSLog(@"A data batch has been received");
}

- (void)excavateLogAtPath:(NSString *)logFilePath {
    BOOL isDir; BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:logFilePath isDirectory:&isDir];
    if (!exists) return;
    if (isDir) {
        NSString *innerXMLPath = [logFilePath stringByAppendingPathComponent:[[[logFilePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xml"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:innerXMLPath]) {
            logFilePath = innerXMLPath;
        } else {
            return;
        }
    }
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:logFilePath isDirectory:NO] options:0 error:nil];
    
    NSXMLElement *rootEl = doc.rootElement;
//    NSSet *me = self.me;
    NSString *me = [[rootEl attributeForName:@"account"].stringValue lowercaseString];
    NSArray *nodes = [doc nodesForXPath:@"/chat/message" error:nil];
    NSMutableArray *lines = [NSMutableArray array];
    NSString *counterpart = nil;
    for (NSXMLElement *element in nodes) {
        NSString *elSender = [[element attributeForName:@"sender"].stringValue lowercaseString];
        if (![me isEqualToString:elSender]) {
            counterpart = elSender;
            [lines addObject:element.stringValue];
        }
    }
    
    if (counterpart != nil) {
        [self.delegate excavator:self foundCorpusAdditions:lines forUsername:counterpart];
    }
}

- (void)initalGatherComplete:(NSNotification *)noti {
    
    NSMetadataQuery *search = self.currentSearch;
    [search stopQuery];

    NSUInteger limit = 2500; // do not use ALL the memory
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger i=0;
        for (i=0; i < limit; i++) {
            NSMetadataItem *theResult = [search resultAtIndex:i];
            NSString *path = [theResult valueForAttribute:NSMetadataItemPathKey];
            [self excavateLogAtPath:path];
            
        }
    
    [self.delegate excavatorFinished:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidUpdateNotification
                                                  object:search];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:search];
    self.currentSearch = nil;
    });
}


- (void)stopLooking {
    if (self.currentSearch != nil) {
        [self.currentSearch stopQuery];
        [self.delegate excavatorFinished:self];
        self.currentSearch = nil;
    }
}
@end
