package sample.tictactoe.multiplayer.entities;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.annotation.EntitySubclass;
import com.googlecode.objectify.annotation.Index;
import java.util.Date;

@EntitySubclass(index=true)
public class PendingGame extends Game
{
	private PendingGame() { super(); }
	
	public PendingGame(User user1, Date dateCreated)
	{
		super(user1, dateCreated);
	}
}