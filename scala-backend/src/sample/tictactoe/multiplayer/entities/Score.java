package sample.tictactoe.multiplayer.entities;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.annotation.EntitySubclass;
import com.googlecode.objectify.annotation.Index;
import java.util.Date;

// A Score is just a completed game (just named Score for clarity purposes elsewhere)
@EntitySubclass(index=true)
public class Score extends Game
{
	@Index private String outcome;
	
	private Score() { super(); }
	
	public Score(Long oldID, User user1, User user2, Date dateFinished, String endingBoard, int playerTurn, String outcome)
	{
		super(oldID, user1, user2, dateFinished, endingBoard, playerTurn);
		this.outcome = outcome;
	}
	
	public String getOutcome() { return outcome; }
	public void setOutcome(String newOutcome) { outcome = newOutcome; }
}