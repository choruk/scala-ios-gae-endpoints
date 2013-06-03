package sample.tictactoe.multiplayer.controllers

import sample.tictactoe.multiplayer.entities._
import com.google.api.server.spi.config.{ Api, ApiMethod }
import com.google.api.server.spi.config.ApiMethod.HttpMethod
import com.google.appengine.api.users.{ User }
import com.google.appengine.api.oauth.OAuthRequestException
import com.googlecode.objectify.ObjectifyService.ofy
import scala.collection.mutable.{ Buffer => MBuff }
import scala.collection.JavaConverters._
import java.util.{ Date, List=>JList }
import java.util.logging.{ Logger, Level }

@Api(
	name = "tictactoe",
	version = "v1",
	clientIds = Array("192939006046.apps.googleusercontent.com")
)
class MatchmakingController
{
	/*val log = Logger.getLogger(classOf[MatchmakingController].getName())
	log.setLevel(Level.INFO)*/
	
	private def checkForUser(user:User) = if (user == null) throw new OAuthRequestException("Invalid user.")
	
	@ApiMethod(
		name = "matchmaking.findOrCreateGame",
		httpMethod = HttpMethod.GET
	)
	def findOrCreateGame(user:User) : Game =
	{
		checkForUser(user)
		val pendingGames:MBuff[PendingGame] = ofy().load().`type`(classOf[PendingGame]).order("date").list().
																						asInstanceOf[JList[PendingGame]].asScala.filter{ pg:PendingGame => pg.getUser1().getEmail() != user.getEmail() }
																						
		if (pendingGames.isEmpty)
		{
			//create a new PendingGame and return it to the user
			val pendingGame = new PendingGame(user, new Date)
			ofy().save().entity(pendingGame).now()
			//log.info("Just created new pending game for " + user.getEmail())
			pendingGame
		}
		else
		{
			//get a PendingGame and create a CurrentGame out of it
			val pendingGame = pendingGames.head			
			val currentGame = new CurrentGame(pendingGame.getID(), pendingGame.getUser1(), user, new Date, pendingGame.getBoard(), pendingGame.getPlayerTurn())
			ofy().delete().entity(pendingGame).now()
			ofy().save().entity(currentGame).now()
			//log.info("Just deleted old pending game for " + pendingGame.getUser1().getEmail() + " and created new current game with " + user.getEmail())
			currentGame
		}
	}
	
}