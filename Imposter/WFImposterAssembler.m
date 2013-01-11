//
//  WFImposterAssembler.m
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "WFImposterAssembler.h"

#import "WFMarkov.h"

@interface WFImposterAssembler ()
@property NSMutableDictionary *corpus;
@property NSUInteger counter;
@end

@implementation WFImposterAssembler
- (NSArray *)tidyAndSplit:(NSString *)str {
    NSRegularExpression *ex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:nil];
    
    NSDataDetector *dd = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink error:nil];
    
    NSString *splPre = [ex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:@" "];
    NSString *spl = [dd stringByReplacingMatchesInString:splPre options:0 range:NSMakeRange(0, splPre.length) withTemplate:@""];
    NSRegularExpression *ex2 = [NSRegularExpression regularExpressionWithPattern:@"[\\p{Ll}\\p{Lu}\\p{Lt}\\p{Lo}\\p{Nd}\\p{Punct}]+" options:0 error:nil];
    NSArray *matches = [ex2 matchesInString:spl options:0 range:NSMakeRange(0, spl.length)];
    NSMutableArray *matchStrings = [NSMutableArray arrayWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        [matchStrings addObject:[spl substringWithRange:match.range]];
    }
    return matchStrings;
}

- (NSString *)makeUpForUsername:(NSString *)username chainLength:(NSUInteger)chainLength wordCount:(NSUInteger)wordCount {
    NSArray *corp = self.corpus[username];
    if (corp == nil) return @"??";
    NSString *allCorp = [corp componentsJoinedByString:@" "];
    NSArray *chainFodder = [self tidyAndSplit:allCorp];
    
    WFMarkovChain *chain = [WFMarkovChain chainWithInput:chainFodder length:chainLength];
    
    NSMutableString *sb = [NSMutableString stringWithCapacity:400];
    [chain generateLazilySequence:^(NSString *part, NSUInteger idx, BOOL *keepGoing) {
        [sb appendFormat:@"%@ ", part];
    } max:wordCount];

    return sb;
}

-(NSArray *)usernames {
    if (self.corpus.count == 0) return @[];
    return self.corpus.allKeys;
}

-(void)excavatorFinished:(WFImposterExcavator *)excavator {
//    NSLog(@"finished; usernames: %@", self.corpus.allKeys);
    for (NSString *username in self.corpus.allKeys) {
        NSUInteger lines = ((NSArray *)self.corpus[username]).count;
        if (lines < 100) [self.corpus removeObjectForKey:username];
    }
    /*
    [self.corpus enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *username = key;
                
        NSLog(@"=== %@ ===", username);
        NSLog(@"%@", sb);

    }];*/
    [self.delegate assemblerReady:self];
}

-(void)excavator:(WFImposterExcavator *)excavator foundCorpusAdditions:(NSArray *)lines forUsername:(NSString *)username {
    NSMutableArray *existingCorpus = self.corpus[username];
    if (existingCorpus == nil) {
        existingCorpus = [lines mutableCopy];
        self.corpus[username] = existingCorpus;
    } else {
        [existingCorpus addObjectsFromArray:lines];
    }
    self.counter++;
    if ((self.counter % 10) == 0) {
        [self.delegate assembler:self progress:self.counter];
    }
}

- (void)startAssembling {
    
    self.corpus = [NSMutableDictionary dictionary];
    
    self.excavator = [[WFImposterExcavator alloc] init];
    self.excavator.delegate = self;
    [self.excavator startLooking];
}
@end
