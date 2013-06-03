package sample.tictactoe.multiplayer.entities

import com.google.appengine.api.users.{ User }
import com.googlecode.objectify.annotation.{ Entity, EntitySubclass, Id, Index }
import com.googlecode.objectify.condition.IfNotNull
import java.util.Date
import java.lang.{ Long => JLong }

@Entity
sealed class Game
{	
	@Id protected var id:JLong = null
	@Index protected var user1:User = null
	@Index(Array(classOf[IfNotNull])) protected var user2:User = null
	@Index protected var date:Date = new Date
	protected var playerTurn:Int = 0
	protected var board:String = "---/---/---"
	
	def getID():JLong = id
	
	def getUser1():User = user1
	def setUser1(user:User) = user1=user
	
	def getUser2():User = user2
	def setUser2(user:User) = user2=user
	
	def getDate():Date = date
	def setDate(_date:Date) = date=_date
	
	def getBoard():String = board
	def setBoard(newBoard:String) = board=newBoard
	
	def getPlayerTurn():Int = playerTurn
	def setPlayerTurn(newPlayerTurn:Int) = playerTurn=newPlayerTurn
}

@EntitySubclass(index=true)
case class PendingGame(firstUser:User, dateCreated:Date)
	extends Game
{
	// Needed for Objectify creation
	private def this() { this(null, null) }
	
	user1 = firstUser
	date = dateCreated
	playerTurn = 1
}

@EntitySubclass(index=true)
case class CurrentGame(oldID:JLong, firstUser:User, secondUser:User, dateSecondUserJoined:Date, _board:String, currentPlayerTurn:Int)
	extends Game
{
	// Needed for Objectify creation
	private def this() { this(null, null, null, null, null, 0) }
	
	id = oldID
	user1 = firstUser
	user2 = secondUser
	date = dateSecondUserJoined
	playerTurn = currentPlayerTurn
	board = _board
}

@EntitySubclass(index=true)
case class Score(oldID:JLong, firstUser:User, secondUser:User, dateFinished:Date, finalBoard:String, finalPlayerTurn:Int, protected var outcome:String)
	extends Game
{	
	// Needed for Objectify creation
	private def this() { this(null, null, null, null, null, 0, null) }
	
	id = oldID
	user1 = firstUser
	user2 = secondUser
	date = dateFinished
	playerTurn = finalPlayerTurn
	board = finalBoard 
	
	def getOutcome():String = outcome
	def setOutcome(newOutcome:String) = outcome=newOutcome
}