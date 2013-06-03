package sample.tictactoe.multiplayer.controllers

import sample.tictactoe.multiplayer.entities._
import com.google.api.server.spi.config.{ Api, ApiMethod }
import com.google.api.server.spi.config.ApiMethod.HttpMethod
import com.google.appengine.api.users.{ User }
import com.google.appengine.api.oauth.OAuthRequestException
import com.googlecode.objectify.ObjectifyService.ofy
import scala.collection.mutable.{ Buffer => MBuff }
import scala.collection.JavaConverters._
import java.util.{ List=>JList }
import java.util.logging.{ Logger, Level }

@Api(
	name = "tictactoe",
	version = "v1",
	clientIds = Array("192939006046.apps.googleusercontent.com")
)
class ScoreController
{
	/*val log = Logger.getLogger(classOf[ScoreController].getName())
	log.setLevel(Level.INFO)*/
	
	private def checkForUser(user:User) = if (user == null) throw new OAuthRequestException("Invalid user.")

	@ApiMethod(
		name = "scores.list",
		httpMethod = HttpMethod.GET
	)
	def list(user:User) : JList[Score] = 
	{
		checkForUser(user)
		val scoreListOne = ofy().load().`type`(classOf[Score]).filter("user1", user).list().asInstanceOf[JList[Score]].asScala
		val scoreListTwo = ofy().load().`type`(classOf[Score]).filter("user2", user).list().asInstanceOf[JList[Score]].asScala
		
		(scoreListOne ++ scoreListTwo).asJava
	}
	
}