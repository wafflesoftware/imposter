//
//  WFImposterAssembler.h
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WFImposterExcavator.h"

@class WFImposterAssembler;

@protocol WFImposterAssemblerDelegate <NSObject>
- (void)assemblerReady:(WFImposterAssembler *)assembler;
- (void)assembler:(WFImposterAssembler *)assembler progress:(NSUInteger)chatCount;
@end

@interface WFImposterAssembler : NSObject <WFImposterExcavatorDelegate>
@property (strong) WFImposterExcavator *excavator;
@property (readonly) NSArray *usernames;
@property (weak) id<WFImposterAssemblerDelegate> delegate;
- (void)startAssembling;
- (NSString *)makeUpForUsername:(NSString *)username chainLength:(NSUInteger)chainLength wordCount:(NSUInteger)wordCount;
@end
