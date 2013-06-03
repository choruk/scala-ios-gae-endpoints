//
//  TTTScoreViewController.h
//  TicTacToe
//
//  Created by Christopher Horuk on 5/25/13.
//  Copyright (c) 2013 FooTangClan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTLTictactoeScore;

@interface TTTScoreViewController : UIViewController

@property NSString *currentUserEmail;
@property GTLTictactoeScore *currentScore;

@end
