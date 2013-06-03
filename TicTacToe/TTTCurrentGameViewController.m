//
//  TTTDetailViewController.m
//  TicTacToe
//
//  Created by Christopher Horuk on 5/15/13.
//  Copyright (c) 2013 FooTangClan. All rights reserved.
//

#import "TTTCurrentGameViewController.h"
#import "GTLTictactoe.h"

#define DEBUG 1

typedef NS_ENUM(NSInteger, TTTGameStatus) {
    TTTGameStatusInProgress = 0,
    TTTGameStatusVictory = 1,
    TTTGameStatusLoss = 2,
    TTTGameStatusTie
};

@interface TTTCurrentGameViewController ()

@property NSNumber *myTurn;
@property NSString *mySymbol;

@property BOOL inQuery;

// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *topLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *topMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *topRightButton;
@property (weak, nonatomic) IBOutlet UIButton *middleLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *middleMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *middleRightButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomMiddleButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomRightButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshGameButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *mySymbolLabel;

- (IBAction)userClickedBoardButton:(id)sender;
- (IBAction)userClickedRefreshButton:(id)sender;

// View configuration
- (void)configureView;
- (void)initializeViewForBoardString:(NSString *)boardString;
- (void)enableGameBoard;
- (void)disableGameBoard;
- (void)inQuery:(BOOL)isTrue enableBoard:(BOOL)enable;

// Managing gameplay
- (void)makeMoveWithNewBoardString:(NSString *)updatedBoardString;
- (void)determineMyTurnNumber;

// Discovering & handling victory
- (TTTGameStatus)checkForVictory:(NSString *)boardString;

@end

@implementation TTTCurrentGameViewController

#pragma mark - View configuration

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self configureView];
}

- (void)configureView
{
    GTLQueryTictactoe *getCurrentGameBoardQuery = [GTLQueryTictactoe queryForGamePlayGetCurrentGameBoardWithObject:self.currentGame];
    
    [self inQuery:YES enableBoard:NO];
    __weak TTTCurrentGameViewController *weakSelf = self;
    [self.ticTacToeService executeQuery:getCurrentGameBoardQuery completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeGame *object, NSError *error) {
        if (!object)
        {
            // Handle the error
            NSLog(@"Error: %@",error.localizedDescription);
            [weakSelf inQuery:NO enableBoard:YES];
        }
        else
        {
            if (![weakSelf.currentGame.board isEqualToString:object.board])
            {
                weakSelf.currentGame = object;
                if ([weakSelf.delegate respondsToSelector:@selector(gameDidChange:atIndex:)])
                    [weakSelf.delegate gameDidChange:object atIndex:weakSelf.currentGameIndex];
            }
            [weakSelf initializeViewForBoardString:object.board];
            [weakSelf determineMyTurnNumber];
            if (object.user2)
                [weakSelf updateTitle];
            else
                weakSelf.title = @"No opponent yet.";
            weakSelf.mySymbolLabel.text = [NSString stringWithFormat:@"Your Symbol: %@",weakSelf.mySymbol];
            
            if (weakSelf.currentGame.playerTurn == weakSelf.myTurn)
                [weakSelf inQuery:NO enableBoard:YES];
            else
                [weakSelf inQuery:NO enableBoard:NO];
        }
    }];
}

//Assumes self.currentGame is currently set to a valid GTLTicTacToeGame object
- (void)updateTitle
{
    if ([self.currentGame.user2.email isEqualToString:self.currentUserEmail])
        self.title = [NSString stringWithFormat:@"Against %@",self.currentGame.user1.email];
    else
        self.title = [NSString stringWithFormat:@"Against %@",self.currentGame.user2.email];
}

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

-(void)enableGameBoard
{
    [self.topLeftButton setEnabled:YES];
    [self.topMiddleButton setEnabled:YES];
    [self.topRightButton setEnabled:YES];
    [self.middleLeftButton setEnabled:YES];
    [self.middleMiddleButton setEnabled:YES];
    [self.middleRightButton setEnabled:YES];
    [self.bottomLeftButton setEnabled:YES];
    [self.bottomMiddleButton setEnabled:YES];
    [self.bottomRightButton setEnabled:YES];
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

-(void)inQuery:(BOOL)isTrue enableBoard:(BOOL)enable
{
    if (isTrue) {
        [self.activityIndicator startAnimating];
        self.inQuery = YES;
        [self.refreshGameButton setEnabled:NO];
    }
    else {
        self.inQuery = NO;
        [self.refreshGameButton setEnabled:YES];
        [self.activityIndicator stopAnimating];
    }
    if (enable)
        [self enableGameBoard];
    else
        [self disableGameBoard];
}

#pragma mark - Managing gameplay

- (IBAction)userClickedBoardButton:(id)sender
{
    if (self.currentGame.playerTurn.intValue == self.myTurn.intValue) {
        [self disableGameBoard];
        NSString *localGameBoard = self.currentGame.board;
        UIButton *clickedButton = sender;
        unichar buffer[localGameBoard.length+1];
        [localGameBoard getCharacters:buffer];
        char currentButtonState = buffer[clickedButton.tag];
        if (strncmp(&currentButtonState, "-", 1) == 0)
        {
            NSString *board = [NSString stringWithCharacters:buffer length:localGameBoard.length];
            board = [board stringByReplacingCharactersInRange:NSMakeRange(clickedButton.tag, 1) withString:self.mySymbol];
            if (DEBUG) {
                NSLog(@"About to submit new board string: %@", board);
            }
            [self makeMoveWithNewBoardString:board];
            if ([self.mySymbol isEqualToString:@"X"])
                [clickedButton setImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
            else
                [clickedButton setImage:[UIImage imageNamed:@"Letter_O.png"] forState:UIControlStateNormal];
        }
        else {
            NSLog(@"Player pressed button other than dash.");
            [self enableGameBoard];
        }
        //[self enableGameBoard];
    }
    else {
        UIAlertView *wrongTurnAlertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"It is not your turn to make a move!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [wrongTurnAlertView show];
    }
}

- (IBAction)userClickedRefreshButton:(id)sender
{
    self.refreshGameButton.enabled = NO;
    
    GTLQueryTictactoe *getCurrentGameBoardQuery = [GTLQueryTictactoe queryForGamePlayGetCurrentGameBoardWithObject:self.currentGame];
    
    [self inQuery:YES enableBoard:NO];
    __weak TTTCurrentGameViewController *weakSelf = self;
    [self.ticTacToeService executeQuery:getCurrentGameBoardQuery completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeGame *object, NSError *error) {
        if (!object)
        {
            // Handle the error
            NSLog(@"Error: %@",error.localizedDescription);
            [weakSelf inQuery:NO enableBoard:YES];
        }
        else
        {
            BOOL checkStatus = NO;
            GTLTictactoeGame *localCurrentGame = weakSelf.currentGame;
            weakSelf.currentGame = object;
            if (object.user2 /*&& !localCurrentGame.user2*/)
                [weakSelf updateTitle];
            if (![object.board isEqualToString:localCurrentGame.board])
            {
                [weakSelf initializeViewForBoardString:object.board];
                checkStatus = YES;
                if ([weakSelf.delegate respondsToSelector:@selector(gameDidChange:atIndex:)])
                    [weakSelf.delegate gameDidChange:object atIndex:weakSelf.currentGameIndex];
            }
            if (checkStatus)
            {
                TTTGameStatus status = [weakSelf checkForVictory:weakSelf.currentGame.board];
                if ( (status == TTTGameStatusInProgress) && (weakSelf.currentGame.playerTurn.intValue == weakSelf.myTurn.intValue) )
                    [weakSelf inQuery:NO enableBoard:YES];
                else if (status == TTTGameStatusInProgress)
                    [weakSelf inQuery:NO enableBoard:NO];
                else
                {
                    [weakSelf inQuery:NO enableBoard:NO];
                    weakSelf.refreshGameButton.enabled = NO;
                    if ([weakSelf.delegate respondsToSelector:@selector(gameDidFinish:atIndex:)])
                        [weakSelf.delegate gameDidFinish:(GTLTictactoeScore *)object atIndex:weakSelf.currentGameIndex];
                }
            }
            else
                [weakSelf inQuery:NO enableBoard:(weakSelf.currentGame.playerTurn.intValue == weakSelf.myTurn.intValue)/* ? YES : NO)*/];
        }
    }];
    //This will be handled within the completionHandler block supplied above
    //self.refreshGameButton.enabled = YES;
}

-(void)makeMoveWithNewBoardString:(NSString *)updatedBoardString
{
    GTLTictactoeGame *updatedGame = self.currentGame;
    updatedGame.board = updatedBoardString;
    
    TTTGameStatus updatedGameStatus = [self checkForVictory:updatedBoardString];
    if (updatedGameStatus == TTTGameStatusInProgress)
    {
        GTLQueryTictactoe *makeMoveQuery = [GTLQueryTictactoe queryForGamePlayUpdateGameWithNewBoardWithObject:updatedGame];
        
        [self inQuery:YES enableBoard:NO];
        __weak TTTCurrentGameViewController *weakSelf = self;
        [self.ticTacToeService executeQuery:makeMoveQuery completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeGame *object, NSError *error) {
            if (!object) {
                // Handle the error
                NSLog(@"Error: %@",error.localizedDescription);
            }
            else {
                NSLog(@"%@",object.board);
                weakSelf.currentGame = object;
                if ([weakSelf.delegate respondsToSelector:@selector(gameDidChange:atIndex:)]) {
                    [weakSelf.delegate gameDidChange:object atIndex:weakSelf.currentGameIndex];
                }
            }
            [weakSelf inQuery:NO enableBoard:NO];
        }];
    }
    else
    {
        if (updatedGameStatus == TTTGameStatusTie)
            updatedGame.playerTurn = 0;
        else if (updatedGameStatus == TTTGameStatusVictory)
            updatedGame.playerTurn = (self.myTurn.intValue == 1) ? @2 : @1;
        
        GTLQueryTictactoe *markGameAsFinishedQuery = [GTLQueryTictactoe queryForGamePlayMarkGameAsFinishedWithObject:updatedGame];
        
        [self inQuery:YES enableBoard:NO];
        __weak TTTCurrentGameViewController *weakSelf = self;
        [self.ticTacToeService executeQuery:markGameAsFinishedQuery completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeScore *object, NSError *error) {
            if (!object) {
                // Handle the error
                NSLog(@"Error: %@",error.localizedDescription);
                [weakSelf inQuery:NO enableBoard:YES];
            }
            else {
                NSLog(@"%@",object.outcome);
                if ([weakSelf.delegate respondsToSelector:@selector(gameDidFinish:atIndex:)]) {
                    [weakSelf.delegate gameDidFinish:object atIndex:weakSelf.currentGameIndex];
                }
                [weakSelf inQuery:NO enableBoard:NO];
            }
        }];
    }
}

-(void)determineMyTurnNumber
{
    if (!self.currentGame) {
        NSLog(@"Should never reach this point.");
        return;
    }
    if ([self.currentGame.user1.email isEqualToString:self.currentUserEmail])
    {
        self.myTurn = @1;
        self.mySymbol = @"X";
    }
    else
    {
        self.myTurn = @2;
        self.mySymbol = @"O";
    }
}

#pragma mark - Discovering & handling victory

-(TTTGameStatus)checkForVictory:(NSString *)boardString
{
    TTTGameStatus finished = TTTGameStatusInProgress;
    
    // Check rows and columns.
    for (int i = 0; i < 3; i++)
    {
        if (!finished)
        {
            NSString *rowString = [self getStringsFrom:boardString atPositions:(i*3)+i:(i*3)+i+1:(i*3)+i+2];
            finished = [self checkSectionVictory:rowString];
        }
        else break;
        
        if (!finished)
        {
            NSString *colString = [self getStringsFrom:boardString atPositions:i:i+4:i+8];
            finished = [self checkSectionVictory:colString];
        }
        else break;
    }
    // Check top-left to bottom-right (if needed).
    if (!finished)
    {
        NSString *diagonal = [self getStringsFrom:boardString atPositions:0:5:10];
        finished = [self checkSectionVictory:diagonal];
    }
    // Check top-right to bottom-left (if needed).
    if (!finished)
    {
        NSString *diagonal = [self getStringsFrom:boardString atPositions:2:5:8];
        finished = [self checkSectionVictory:diagonal];
    }
    // Check for tie (if needed).
    if (!finished)
    {
        NSRange range = [boardString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        if (range.location == NSNotFound) {
            finished = TTTGameStatusTie;
        }
    }
    
    return finished;
}

- (NSString *)getStringFrom:(NSString *)string atPosition:(int)position
{
    return [NSString stringWithFormat:@"%C", [string characterAtIndex:position]];
}

- (NSString *)getStringsFrom:(NSString *)string atPositions:(int)first
                                                           :(int)second
                                                           :(int)third
{
    return [NSString stringWithFormat:@"%@%@%@",
            [self getStringFrom:string atPosition:first],
            [self getStringFrom:string atPosition:second],
            [self getStringFrom:string atPosition:third]];
}

- (TTTGameStatus)checkSectionVictory:(NSString *)section
{
    char a = [section characterAtIndex:0];
    char b = [section characterAtIndex:1];
    char c = [section characterAtIndex:2];
    if (a == b && a == c && a != '-')
    {
        if (a == [self.mySymbol characterAtIndex:0])
            return TTTGameStatusVictory;
        else
            return TTTGameStatusLoss;
    }
    return TTTGameStatusInProgress;
}

@end
