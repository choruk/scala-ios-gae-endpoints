//
//  TTTDetailViewController.h
//  TicTacToe
//
//  Created by Christopher Horuk on 5/15/13.
//  Copyright (c) 2013 FooTangClan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTLTictactoeGame;
@class GTLTictactoeScore;
@class GTLServiceTictactoe;

@protocol TTTCurrentGameViewDelegate;

@interface TTTCurrentGameViewController : UIViewController

@property NSString *currentUserEmail;
@property GTLTictactoeGame *currentGame;
@property NSInteger currentGameIndex;
@property GTLServiceTictactoe *ticTacToeService;
@property (weak, nonatomic) id<TTTCurrentGameViewDelegate> delegate;

@end

@protocol TTTCurrentGameViewDelegate <NSObject>

-(void)gameDidChange:(GTLTictactoeGame *)updatedGame atIndex:(NSInteger)index;
-(void)gameDidFinish:(GTLTictactoeScore *)completedGame atIndex:(NSInteger)index;

@end