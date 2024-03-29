/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLTictactoeScoreCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   tictactoe/v1
// Description:
//   This is an API
// Classes:
//   GTLTictactoeScoreCollection (0 custom class methods, 1 custom properties)

#import "GTLTictactoeScoreCollection.h"

#import "GTLTictactoeScore.h"

// ----------------------------------------------------------------------------
//
//   GTLTictactoeScoreCollection
//

@implementation GTLTictactoeScoreCollection
@dynamic items;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLTictactoeScore class]
                                forKey:@"items"];
  return map;
}

@end
