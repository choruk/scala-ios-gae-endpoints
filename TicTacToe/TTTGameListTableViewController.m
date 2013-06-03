//
//  TTTMasterViewController.m
//  TicTacToe
//
//  Created by Christopher Horuk on 5/15/13.
//  Copyright (c) 2013 FooTangClan. All rights reserved.
//

#import "TTTGameListTableViewController.h"
#import "TTTCurrentGameViewController.h"
#import "TTTScoreViewController.h"

#import "GTLTictactoe.h"

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPFetcherLogging.h"

// GAE-related globals
static NSString *const kKeychainItemName = @"ScalaOnGAE Sample: TicTacToe";
NSString *kMyClientID = @"192939006046.apps.googleusercontent.com";     // pre-assigned by service
NSString *kMyClientSecret = @"c4rrUJH1BNhI5eSl8dWMxRt9"; // pre-assigned by service
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email"; // scope for email

// Segue Identifiers
static NSString *const kCurrentGameSegueIdentifier = @"ShowCurrentGame";
static NSString *const kCurrentScoreSegueIdentifier = @"ShowCurrentScore";

@interface TTTGameListTableViewController () <UITableViewDelegate, UITableViewDataSource, TTTCurrentGameViewDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *findGameButton;

// Authentication-related properties
@property BOOL signedIn;
@property NSString *userEmail;

// Tableview-related properties
@property NSMutableArray *currentGames;
@property NSMutableArray *completedGames;

// For updating game description text
@property BOOL shouldSortCurrentGames;
@property BOOL shouldSortCompletedGames;

// To ensure we are done with all queries before updating animations
@property BOOL inCurrentGameQuery;
@property BOOL inScoreQuery;

// Remote API handling
- (GTLServiceTictactoe *)ticTacToeService;
- (void)getUsersCurrentGamesFromServer;
- (void)getUsersScoresFromServer;

// IBActions
- (IBAction)signIn:(id)sender;
- (IBAction)findNewGame:(id)sender;

// Query-related interface update
- (void)inQuery:(BOOL)isTrue;

@end

@implementation TTTGameListTableViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.signedIn = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureViewForUser:self.signedIn];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.shouldSortCurrentGames)
    {
        [self.currentGames sortUsingComparator:^NSComparisonResult(GTLTictactoeGame *game1, GTLTictactoeGame *game2) {
            return [game2.date.date compare:game1.date.date];
        }];
        [self.tableView reloadData];
        self.shouldSortCurrentGames = NO;
    }
    if (self.shouldSortCompletedGames)
    {
        [self.completedGames sortUsingComparator:^NSComparisonResult(GTLTictactoeGame *game1, GTLTictactoeGame *game2) {
            return [game2.date.date compare:game1.date.date];
        }];
        [self.tableView reloadData];
        self.shouldSortCompletedGames = NO;
    }
}

- (void)configureViewForUser:(BOOL)signedIn
{
    if (signedIn)
    {
        [self.signInButton setTitle:@"Sign Out"];
        [self.findGameButton setEnabled:YES];
        [self getUsersCurrentGamesFromServer];
        [self getUsersScoresFromServer];
        //[self.tableView reloadData];
    }
    else
    {
        [self.signInButton setTitle:@"Sign In"];
        [self.findGameButton setEnabled:NO];
        self.currentGames = nil;
        self.completedGames = nil;
        [self.tableView reloadData];
    }
}

-(void)inQuery:(BOOL)isTrue
{
    if (isTrue)
    {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.tableView.tableHeaderView = activityIndicator;
        [activityIndicator startAnimating];
        
        [self.findGameButton setEnabled:NO];
        self.tableView.allowsSelection = NO;
    }
    else {
        if (self.inScoreQuery || self.inCurrentGameQuery) {
            return;
        }
        [self.findGameButton setEnabled:YES];
        self.tableView.allowsSelection = YES;
        
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.tableView.tableHeaderView;
        [activityIndicator stopAnimating];
        self.tableView.tableHeaderView = nil;
    }
}

#pragma mark - Authentication Handling

- (IBAction)signIn:(id)sender
{
    if (!self.signedIn) {
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                clientID:kMyClientID
                                                            clientSecret:kMyClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
        [self presentViewController:viewController animated:YES completion:NULL];
    }
    else {
        self.signedIn = NO;
        self.userEmail = @"";
        [self configureViewForUser:NO];
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (error != nil) {
        // Authentication failed
        [self.signInButton setTitle:@"Retry"];
    }
    else {
        // Authentication succeeded
        self.signedIn = YES;
        [[self ticTacToeService] setAuthorizer:auth];
        auth.authorizationTokenKey = @"id_token";
        self.userEmail = auth.userEmail;
        [self configureViewForUser:YES];
        
        /*[[self tictactoeService] setAuthorizer:auth];
         auth.authorizationTokenKey = @"id_token";
         [userLabel setText:auth.userEmail];
         [victory setText:@""];
         [self setBoardEnablement:true];
         [self queryScores];*/
    }
}

#pragma mark - 

- (IBAction)findNewGame:(id)sender
{
    self.findGameButton.enabled = NO;
    
    GTLServiceTictactoe *ticTacToeService = [self ticTacToeService];
    GTLQueryTictactoe *findGameQuery = [GTLQueryTictactoe queryForMatchmakingFindOrCreateGame];
    
    [self inQuery:YES];
    self.inCurrentGameQuery = YES;
    __weak TTTGameListTableViewController *weakSelf = self;
    [ticTacToeService executeQuery:findGameQuery completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeGame *object, NSError *error) {
        if (!object) {
            // Handle the error
            NSLog(@"Error: %@",error.localizedDescription);
            weakSelf.findGameButton.enabled = YES;
        }
        else {
            // Update the list of current games for this user.
            [weakSelf.currentGames addObject:object];
            
            // Insert a new row for the new game.
            NSIndexPath *newCellIndexPath = [NSIndexPath indexPathForRow:weakSelf.currentGames.count-1 inSection:0];
            [weakSelf.tableView insertRowsAtIndexPaths:@[ newCellIndexPath ] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView scrollToRowAtIndexPath:newCellIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            
            // Segue to the new game and re-enable the find game button.
            UITableViewCell *selectedCell = [weakSelf.tableView cellForRowAtIndexPath:newCellIndexPath];
            [weakSelf performSegueWithIdentifier:kCurrentGameSegueIdentifier sender:selectedCell];
            weakSelf.findGameButton.enabled = YES;
        }
        weakSelf.inCurrentGameQuery = NO;
        [weakSelf inQuery:NO];
    }];
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kCurrentGameSegueIdentifier]) {
        TTTCurrentGameViewController *destinationViewController = (TTTCurrentGameViewController *)segue.destinationViewController;
        
        // can now pass on any needed info to the current game view controller
        NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForCell:sender];
        GTLTictactoeGame *selectedGame = (GTLTictactoeGame *)self.currentGames[selectedCellIndexPath.row];
        destinationViewController.currentUserEmail = self.userEmail;
        destinationViewController.currentGame = selectedGame;
        destinationViewController.currentGameIndex = selectedCellIndexPath.row;
        destinationViewController.ticTacToeService = [self ticTacToeService];
        destinationViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:kCurrentScoreSegueIdentifier])
    {
        TTTScoreViewController *destinationViewController = (TTTScoreViewController *)segue.destinationViewController;
        NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForCell:sender];
        GTLTictactoeScore *selectedScore = (GTLTictactoeScore *)self.completedGames[selectedCellIndexPath.row];
        destinationViewController.currentUserEmail = self.userEmail;
        destinationViewController.currentScore = selectedScore;
    }
}

#pragma mark - Remote API Handling

-(GTLServiceTictactoe *)ticTacToeService
{
    static GTLServiceTictactoe *service = nil;
    
    if (!service)
    {
        service = [[GTLServiceTictactoe alloc] init];
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
        
        [GTMHTTPFetcher setLoggingEnabled:YES];
    }
    
    return service;
}

-(void)getUsersCurrentGamesFromServer
{
    GTLQueryTictactoe *currentGamesQuery = [GTLQueryTictactoe queryForGamesList];
    [self inQuery:YES];
    self.inCurrentGameQuery = YES;
    __weak TTTGameListTableViewController *weakSelf = self;
    [[self ticTacToeService] executeQuery:currentGamesQuery completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeGameCollection *object, NSError *error) {
        if (!object)
        {
            // Handle the error
            NSLog(@"Error: %@",error.localizedDescription);
        }
        else
        {
            weakSelf.currentGames = object.items.mutableCopy;
            [weakSelf.currentGames sortUsingComparator:^NSComparisonResult(GTLTictactoeGame *game1, GTLTictactoeGame *game2) {
                return [game2.date.date compare:game1.date.date];
            }];
            [weakSelf.tableView reloadData];
        }
        weakSelf.inCurrentGameQuery = NO;
        [weakSelf inQuery:NO];
    }];
}

-(void)getUsersScoresFromServer
{
    GTLQueryTictactoe *scoresQuery = [GTLQueryTictactoe queryForScoresList];
    [self inQuery:YES];
    self.inScoreQuery = YES;
    __weak TTTGameListTableViewController *weakSelf = self;
    [[self ticTacToeService] executeQuery:scoresQuery completionHandler:^(GTLServiceTicket *ticket, GTLTictactoeScoreCollection *object, NSError *error) {
        if (!object)
        {
            // Handle the error
            NSLog(@"Error: %@",error.localizedDescription);
        }
        else
        {
            weakSelf.completedGames = object.items.mutableCopy;
            [weakSelf.completedGames sortUsingComparator:^NSComparisonResult(GTLTictactoeGame *game1, GTLTictactoeGame *game2) {
                return [game2.date.date compare:game1.date.date];
            }];
            [weakSelf.tableView reloadData];
        }
        weakSelf.inScoreQuery = NO;
        [weakSelf inQuery:NO];
    }];
}

#pragma mark - UITableViewDatasource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Table View Identifiers
    static NSString *const kCurrentGameCellIdentifier = @"CurrentGameCell";
    static NSString *const kCompletedGameCellIdentifier = @"CompleteGameCell";
    
    static NSDateFormatter *kDateFormatter = nil;
    if (!kDateFormatter) {
        kDateFormatter =[[NSDateFormatter alloc] init];
        kDateFormatter.timeStyle = NSDateFormatterShortStyle;
        kDateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kCurrentGameCellIdentifier];
        cell.textLabel.text = ((GTLTictactoeGame *)self.currentGames[indexPath.row]).board;
        cell.detailTextLabel.text = [kDateFormatter stringFromDate:[((GTLTictactoeGame *)self.currentGames[indexPath.row]).date date]];
    }
    else if (indexPath.section == 1)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kCompletedGameCellIdentifier];
        cell.textLabel.text = [((GTLTictactoeScore *)self.completedGames[indexPath.row]) JSONValueForKey:@"outcome"]; // .outcome;
        cell.detailTextLabel.text = [kDateFormatter stringFromDate:[((GTLTictactoeScore *)self.completedGames[indexPath.row]).date date]];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.currentGames.count;
    else if (section == 1)
        return self.completedGames.count;
    else
        return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Current Games";
    else if (section == 1)
        return @"Completed Games";
    else
        return nil;
}

#pragma mark - TTTCurrentGameViewDelegate methods

-(void)gameDidChange:(GTLTictactoeGame *)updatedGame atIndex:(NSInteger)gameIndex
{
    [self.currentGames replaceObjectAtIndex:gameIndex withObject:updatedGame];
    self.shouldSortCurrentGames = YES;
}

-(void)gameDidFinish:(GTLTictactoeScore *)completedGame atIndex:(NSInteger)index
{
    [self.currentGames removeObjectAtIndex:index];
    [self.completedGames addObject:completedGame];
    self.shouldSortCompletedGames = YES;
}

@end
