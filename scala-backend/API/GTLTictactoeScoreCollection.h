/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLTictactoeScoreCollection.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   tictactoe/v1
// Description:
//   This is an API
// Classes:
//   GTLTictactoeScoreCollection (0 custom class methods, 1 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLTictactoeScore;

// ----------------------------------------------------------------------------
//
//   GTLTictactoeScoreCollection
//

// This class supports NSFastEnumeration over its "items" property. It also
// supports -itemAtIndex: to retrieve individual objects from "items".

@interface GTLTictactoeScoreCollection : GTLCollectionObject
@property (retain) NSArray *items;  // of GTLTictactoeScore
@end