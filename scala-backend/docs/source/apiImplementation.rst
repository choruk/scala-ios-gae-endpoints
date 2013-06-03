==============================
The Backend API Implementation
==============================

TALK ABOUT: INABILITY TO QUERY BY ONE PROPERTY AND SORT BY OTHER UNLESS EQUALITY QUERY, INABILITY TO RETURN SCALA TYPES (due to serialization), INABILITY TO GET ALL GAMES WITH A SINGLE QUERY

The development process, as discussed in the Google Cloud Endpoints section of the Techonologies page, for an App Engine API backend is very straightforward. The TicTacToe application splits the API between three different controllers to manage the three unique aspects of the application: a *MatchmakingController* for the matchmaking system to find a game, a *GamePlayController* for managing game play and a *ScoreController* for displaying completed games. The APIs that these controllers implement all require authentication, evidenced by the *checkForUser()* method called at the start of each API.

Limitations
-----------

Certain limitations were introduced into the API backend due to App Engine restrictions and conflicting technologies. To allow App Engine to efficiently load values from the datastore, only queries with a certain structure are allowed to be executed. Google `explicitly documents`_ the restrictions on datastore queries and these restrictions introduced a few limitations within the TicTacToe application. Within the *findOrCreateGame()* method of the *MatchmakingController* class, the first limitation is introduced with the following line:

.. _explicitly documents: https://developers.google.com/appengine/docs/java/datastore/queries#Restrictions_on_Queries

.. code-block:: scala

	val pendingGames:MBuff[PendingGame] = ofy().load().`type`(classOf[PendingGame]).order("date").list().asInstanceOf[JList[PendingGame]].asScala.filter{ pg:PendingGame => pg.getUser1().getEmail() != user.getEmail() }

This code line is retrieving a list of all *PendingGame* objects that were not created by this user, i.e. all pending games that this user can join. This list is ordered by the *date* property of each *PendingGame* object such that the oldest pending game is first in the list. In this way, the player who has been waiting for a second competitor the longest will be the one whose game the new player joins. However, one of the query restrictions is that properties used in inequality filters (i.e. any filter besides *==*) must be sorted first. This restriction would mean that we would have to order first by *user1* and then by *date* and players with emails that start with the character a would get the greatest priority. Luckily, it is safe to assume that this player won't have many *PendingGame* objects in the datastore and thus not much of an extra hit is taken simply by letting the datastore order by *date* and then filtering the result.


The other hoop to jump around is due to the inability of the endpoints tool to serialize Scala classes. This inability causes the endpoints tool to throw an exception when it runs into a method whose return type involves a class specific to Scala. Luckily, the fix for this issue is simple: the *scala.collection.JavaConverters* package provides a simple way to convert back and forth between certain Scala and Java classes. Using this package, you can simply use *asScala* or *asJava* to accurately convert between certain supported types.