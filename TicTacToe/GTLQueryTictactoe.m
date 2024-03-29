/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLQueryTictactoe.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   tictactoe/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryTictactoe (6 custom class methods, 1 custom properties)

#import "GTLQueryTictactoe.h"

#import "GTLTictactoeGame.h"
#import "GTLTictactoeGameCollection.h"
#import "GTLTictactoeScore.h"
#import "GTLTictactoeScoreCollection.h"

@implementation GTLQueryTictactoe

@dynamic fields;

#pragma mark -
#pragma mark "gamePlay" methods
// These create a GTLQueryTictactoe object.

+ (id)queryForGamePlayGetCurrentGameBoardWithObject:(GTLTictactoeGame *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"tictactoe.gamePlay.getCurrentGameBoard";
  GTLQueryTictactoe *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLTictactoeGame class];
  return query;
}

+ (id)queryForGamePlayMarkGameAsFinishedWithObject:(GTLTictactoeGame *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"tictactoe.gamePlay.markGameAsFinished";
  GTLQueryTictactoe *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLTictactoeScore class];
  return query;
}

+ (id)queryForGamePlayUpdateGameWithNewBoardWithObject:(GTLTictactoeGame *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"tictactoe.gamePlay.updateGameWithNewBoard";
  GTLQueryTictactoe *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLTictactoeGame class];
  return query;
}

#pragma mark -
#pragma mark "games" methods
// These create a GTLQueryTictactoe object.

+ (id)queryForGamesList {
  NSString *methodName = @"tictactoe.games.list";
  GTLQueryTictactoe *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [GTLTictactoeGameCollection class];
  return query;
}

#pragma mark -
#pragma mark "matchmaking" methods
// These create a GTLQueryTictactoe object.

+ (id)queryForMatchmakingFindOrCreateGame {
  NSString *methodName = @"tictactoe.matchmaking.findOrCreateGame";
  GTLQueryTictactoe *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [GTLTictactoeGame class];
  return query;
}

#pragma mark -
#pragma mark "scores" methods
// These create a GTLQueryTictactoe object.

+ (id)queryForScoresList {
  NSString *methodName = @"tictactoe.scores.list";
  GTLQueryTictactoe *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [GTLTictactoeScoreCollection class];
  return query;
}

@end
