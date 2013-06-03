==================
Playing TicTacToe
==================

The TicTacToe game is implemented such that a player can create a *PendingGame* and immediately play their first turn without having to wait for an opponent. When an opponent joins the game, the game becomes a *CurrentGame* and the *date* updates after every turn. When a game finishes, it becomes a *Score* and maintains an *outcome* that reflects the final game board.

The main view of the iOS client app is a table view that displays all of the users current and completed games once they sign in. The application is designed to be as scalable as possible. For example, selecting a current game will transition that game to the main screen and query the backend for the most recent copy. If the copy currently stored in the main table view of the client application is different from the one retrieved from the backend, the old copy is replaced with the updated copy. By doing so, the client application only needs to perform the more expensive list queries once after the user signs in. Likewise, while the client could poll the API backend to check for the other player's turn, it instead provides a refresh button that the user can press to query the backend for any updates to the game. Should it detect an update, the same process is applied to update the main table view as before.

All of the logic for checking the status of a game is placed client-side to further reduce the burden on the backend. When a game finishes and becomes a *Score*, it keeps the same ID, which ensures that a user won't see an error when a game they are currently viewing ends. The *outcome* property of every *Score* is a *String* structured so that unless the outcome is a tie, the first word is the email of the winner followed by "defeated" followed by the email of the loser. This structure allows the client application to display some more meaningful information to the users when viewing *Scores*.


