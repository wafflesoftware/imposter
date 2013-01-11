//
//  WFImposterExcavator.h
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WFImposterExcavator;

@protocol WFImposterExcavatorDelegate <NSObject>
-(void)excavator:(WFImposterExcavator *)excavator foundCorpusAdditions:(NSArray *)lines forUsername:(NSString *)username;
-(void)excavatorFinished:(WFImposterExcavator *)excavator;
@end

@interface WFImposterExcavator : NSObject <NSMetadataQueryDelegate>
@property (weak) id<WFImposterExcavatorDelegate> delegate;
- (void)startLooking;
- (void)stopLooking;
@end
