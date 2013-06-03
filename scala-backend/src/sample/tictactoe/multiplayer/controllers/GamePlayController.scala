package sample.tictactoe.multiplayer.controllers

import sample.tictactoe.multiplayer.entities._//{ Game, PendingGame, CurrentGame, Score }
import com.google.api.server.spi.config.{ Api, ApiMethod }
import com.google.api.server.spi.config.ApiMethod.HttpMethod
import com.google.appengine.api.users.{ User }
import com.google.appengine.api.oauth.OAuthRequestException
import com.googlecode.objectify.ObjectifyService.ofy
import scala.collection.mutable.{ Buffer => MBuff }
import scala.collection.JavaConverters._
import scala.util.control.Breaks._
import java.util.{ Date, List=>JList }
import java.util.logging.{ Logger, Level }
import com.googlecode.objectify.Ref

@Api(
	name = "tictactoe",
	version = "v1",
	clientIds = Array("192939006046.apps.googleusercontent.com")
)
class GamePlayController
{
	/*val log = Logger.getLogger(classOf[GamePlayController].getName())
	log.setLevel(Level.INFO)*/
	
	private def checkForUser(user:User) = if (user == null) throw new OAuthRequestException("Invalid user.")

	@ApiMethod(
		name = "games.list",
		path = "games",
		httpMethod = HttpMethod.GET
	)
	def list(user:User) : JList[Game] =
	{
		checkForUser(user)
		val pendingList = ofy().load().`type`(classOf[PendingGame]).filter("user1", user).list().asInstanceOf[JList[Game]].asScala
		val currentListOne = ofy().load().`type`(classOf[CurrentGame]).filter("user1", user).list().asInstanceOf[JList[Game]].asScala
		val currentListTwo = ofy().load().`type`(classOf[CurrentGame]).filter("user2", user).list().asInstanceOf[JList[Game]].asScala

		(pendingList ++ currentListOne ++ currentListTwo).asJava
	}
	
	@ApiMethod(
		name = "gamePlay.getCurrentGameBoard",
		httpMethod = HttpMethod.GET
	)
	def getCurrentGameBoard(user:User, inputGame:Game) : Game =
	{
		checkForUser(user)
		ofy().load.`type`(classOf[Game]).id(inputGame.getID()).now()
		/*
		val currentGame = ofy().load.`type`(classOf[Game]).id(inputGame.getID()).now()
		val currentGameAsScore = if (currentGame == null) ofy().load.`type`(classOf[Score]).id(inputGame.getID()).now() *//*filter("user1", currentGame.getUser1()).filter("user2", currentGame.getUser2()).
																										 order("-date").list().asInstanceOf[java.util.List[PendingGame]].asScala.head*/
		/*												 else null
		if (currentGameAsScore == null)
			currentGame
		else
			currentGameAsScore*/
	}
	
	@ApiMethod(
		name = "gamePlay.updateGameWithNewBoard",
		httpMethod = HttpMethod.PUT
	)
	def makeMoveWithBoard(user:User, updatedGame:Game) : Game =
	{
		checkForUser(user)
		// Needed to ensure the type of the game we are updating is maintained within the DB
		val typeSpecificUpdatedGame = ofy().load.`type`(classOf[Game]).id(updatedGame.getID()).now()/*if (updatedGame.getUser2() == null) ofy().load.`type`(classOf[PendingGame]).id(updatedGame.getID()).now()
																	else ofy().load.`type`(classOf[CurrentGame]).id(updatedGame.getID()).now()*/
		// Since this represents someones turn, update the playerTurn property as well
		val updatedTurn = if (typeSpecificUpdatedGame.getPlayerTurn() == 1) 2 else 1
		typeSpecificUpdatedGame.setPlayerTurn(updatedTurn)
		typeSpecificUpdatedGame.setBoard(updatedGame.getBoard())
		typeSpecificUpdatedGame.setDate(new Date)
		
		ofy().save().entity(typeSpecificUpdatedGame).now()
		//log.info("Just updated game between " + typeSpecificUpdatedGame.getUser1().getEmail() + " and " + typeSpecificUpdatedGame.getUser2().getEmail() + " with " + typeSpecificUpdatedGame.getBoard())
		typeSpecificUpdatedGame
	}
	
	@ApiMethod(
		name = "gamePlay.markGameAsFinished",
		httpMethod = HttpMethod.POST
	)
	def markGameAsFinished(user:User, finishedGame:Game) : Score = 
	{
		checkForUser(user)
		// Make the outcome string
		val outcome = if (finishedGame.getPlayerTurn() == 0) "Tie!"
									else if (finishedGame.getPlayerTurn() == 1) finishedGame.getUser2().getEmail() + " defeated " + finishedGame.getUser1().getEmail()
									else finishedGame.getUser1().getEmail() + " defeated " + finishedGame.getUser2().getEmail()
		// Make the Score entity
		val gameScore = new Score(finishedGame.getID(), finishedGame.getUser1(), finishedGame.getUser2(), new Date, finishedGame.getBoard(), finishedGame.getPlayerTurn(), outcome)
		ofy().delete().entity(finishedGame).now()
		ofy().save().entity(gameScore).now()
		//log.info("Just finished game between " + gameScore.getUser1().getEmail() + " and " + gameScore.getUser2().getEmail() + " with outcome " + gameScore.getOutcome())
		gameScore
	}
}

/*object GameController
{
	val DEBUG=true
}*/