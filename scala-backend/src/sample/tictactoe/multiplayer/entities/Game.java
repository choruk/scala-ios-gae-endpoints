package sample.tictactoe.multiplayer.entities;

import com.google.appengine.api.users.User;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import com.googlecode.objectify.condition.IfNotNull;
import java.util.Date;

@Entity
public class Game
{
	@Id protected Long id;
	@Index protected User user1;
	@Index({IfNotNull.class}) protected User user2;
	@Index protected Date date;
	protected String gameBoard;
	protected int playerTurn;
	
	protected Game() {}
		
	public Game(User user1, Date date)
	{
		this.user1 = user1;
		this.user2 = null;
		this.date = date;
		this.gameBoard = "---/---/---";
		this.playerTurn = 1;
	}
	
	public Game(Long id, User user1, User user2, Date date, String gameBoard, int playerTurn)
	{
		this.id = id;
		this.user1 = user1;
		this.user2 = user2;
		this.date = date;
		this.gameBoard = gameBoard;
		this.playerTurn = playerTurn;
	}
	
	public Long getID() { return id; }
	
	public User getUser1() { return user1; }
	public void setUser1(User newUser1) { user1 = newUser1; }
	
	public User getUser2() { return user2; }
	public void setUser2(User newUser2) { user2 = newUser2; }
	
	public Date getDate() { return date; }
	public void setDate(Date newDate) { date = newDate; }
	
	public String getBoard() { return gameBoard; }
	public void setBoard(String newBoard) { gameBoard = newBoard; }
	
	public int getPlayerTurn() { return playerTurn; }
	public void setPlayerTurn(int nextTurn) {	playerTurn = nextTurn; }
}