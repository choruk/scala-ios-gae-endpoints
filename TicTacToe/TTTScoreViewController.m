//
//  TTTScoreViewController.m
//  TicTacToe
//
//  Created by Christopher Horuk on 5/25/13.
//  Copyright (c) 2013 FooTangClan. All rights reserved.
//

#import "TTTScoreViewController.h"
#import "GTLTictactoe.h"

@interface TTTScoreViewController ()

@property (weak, nonatomic) IBOutlet UIButton *topLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *topMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *topRightButton;
@property (weak, nonatomic) IBOutlet UIButton *middleLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *middleMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *middleRightButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomRightButton;
@property (weak, nonatomic) IBOutlet UILabel *outcomeLabel;

@end

@implementation TTTScoreViewController

- (void)initializeViewForBoardString:(NSString *)boardString
{
    unichar buffer[boardString.length+1];
    [boardString getCharacters:buffer range:NSMakeRange(0, boardString.length)];
    for (int i=0; i<boardString.length; i++) {
        char c = buffer[i];
        if (strncmp(&c,"X",1)==0)
            [((UIButton *)[self.view viewWithTag:i]) setImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
        else if (strncmp(&c,"O",1)==0)
            [((UIButton *)[self.view viewWithTag:i]) setImage:[UIImage imageNamed:@"Letter_O.png"] forState:UIControlStateNormal];
        else if (strncmp(&c,"-",1)==0)
            [((UIButton *)[self.view viewWithTag:i]) setImage:[UIImage imageNamed:@"non_breaking_hyphen_u2011_icon_256x256.png"] forState:UIControlStateNormal];
        else
            NSLog(@"Char is %c",c);
    }
}

- (void)modifyOutcomeMessageForCurrentUser
{
    char *TIE = "Tie!";
    NSString *outcome = [self.currentScore JSONValueForKey:@"outcome"];
    
    if (strncmp(outcome.UTF8String, TIE, strlen(TIE)) == 0)
    {
        self.title = [NSString stringWithCString:TIE encoding:NSUTF8StringEncoding];
        if ([self.currentScore.user1.email isEqualToString:self.currentUserEmail])
            self.outcomeLabel.text = [NSString stringWithFormat:@"You tied with %@",self.currentScore.user2.email];
        else
            self.outcomeLabel.text = [NSString stringWithFormat:@"You tied with %@",self.currentScore.user1.email];
    }
    else if (strncmp(outcome.UTF8String, self.currentUserEmail.UTF8String, strlen(self.currentUserEmail.UTF8String)) == 0)
    {
        self.title = @"Victory!";
        self.outcomeLabel.text = [outcome stringByReplacingOccurrencesOfString:self.currentUserEmail withString:@"You"];
    }
    else
    {
        self.title = @"Defeat!";
        self.outcomeLabel.text = [outcome stringByReplacingOccurrencesOfString:self.currentUserEmail withString:@"you"];
    }
    
}

-(void)disableGameBoard
{
    [self.topLeftButton setEnabled:NO];
    [self.topMiddleButton setEnabled:NO];
    [self.topRightButton setEnabled:NO];
    [self.middleLeftButton setEnabled:NO];
    [self.middleMiddleButton setEnabled:NO];
    [self.middleRightButton setEnabled:NO];
    [self.bottomLeftButton setEnabled:NO];
    [self.bottomMiddleButton setEnabled:NO];
    [self.bottomRightButton setEnabled:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initializeViewForBoardString:self.currentScore.board];
    [self modifyOutcomeMessageForCurrentUser];
    [self disableGameBoard];
}

@end
