/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLTictactoeGameCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   tictactoe/v1
// Description:
//   This is an API
// Classes:
//   GTLTictactoeGameCollection (0 custom class methods, 1 custom properties)

#import "GTLTictactoeGameCollection.h"

#import "GTLTictactoeGame.h"

// ----------------------------------------------------------------------------
//
//   GTLTictactoeGameCollection
//

@implementation GTLTictactoeGameCollection
@dynamic items;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLTictactoeGame class]
                                forKey:@"items"];
  return map;
}

@end
