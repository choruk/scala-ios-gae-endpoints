package sample.tictactoe.multiplayer.startup

import sample.tictactoe.multiplayer.entities._
import javax.servlet.{ ServletContext, ServletContextEvent, ServletContextListener }
import com.googlecode.objectify.ObjectifyService
import java.util.logging.{ Logger, Level }

class MyListener extends ServletContextListener
{
	// This will be invoked by App Engine as part of a warmup request,
	// or the first user request if no warmup request was invoked.
	def contextInitialized(event:ServletContextEvent) =
	{		
		// Register Objectify entities
		ObjectifyService.register(classOf[Game])
		ObjectifyService.register(classOf[PendingGame])
		ObjectifyService.register(classOf[CurrentGame])
		ObjectifyService.register(classOf[Score])
		// Configure the global logger to INFO level
		Logger.getLogger(Logger.GLOBAL_LOGGER_NAME).setLevel(Level.INFO)
	}
	// Not supported by App Engine
	def contextDestroyed(event:ServletContextEvent) = ()
}