package sample.tictactoe.multiplayer.entities;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.annotation.EntitySubclass;
import com.googlecode.objectify.annotation.Index;
import java.util.Date;

@EntitySubclass(index=true)
public class CurrentGame extends Game
{
	private CurrentGame() { super(); }
	
	public CurrentGame(Long oldID, User user1, User user2, Date dateUser2Joined, String board, int playerTurn)
	{
		super(oldID, user1, user2, dateUser2Joined, board, playerTurn);
	}
}