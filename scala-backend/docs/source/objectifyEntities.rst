======================
Modeling The Entities
======================

As mentioned in the Technologies section, the Objectify framework was used to interact with the App Engine datastore. When starting a project that uses Objectify, you first need to model the entities that your application will be placing into the datastore. You then annotate your entities properly, following the `official documentation`_, and you are ready to start storing and loading your data.

.. _official documentation: http://code.google.com/p/objectify-appengine/wiki/Entities

Objectify Configurations
------------------------

All of the entities used by the TicTacToe application inherit from a common base class named *Game* and can be found in the *Game.scala* file. The *Game* base class is labeled with the *@Entity* annotation, while the subclasses are labeled with the *@EntitySubclass* annotation; displaying Objectify polymorphism in action. The *index=true* specification on the annotations of the subclasses lets Objectify know that we wan't to query on these classes. Behind the scenes, Objectify is actually creating another property on our entities specifying their underlying class type. Objectify also requires all entities to have a no-arg constructor, which explains the private *this()* methods in all of the subclasses.

	**Note:** Scala creates a no-arg constructor for the Game base class implicitly.
	
Another important Objectify-related configuration lies in the use of the *@Index* annotations. As per the `best practices`_, you should use indexes sparingly and only on properties that you will need to query on. For this reason, only the *user1*, *user2*, and *date* properties are indexed in TicTacToe's entities.

.. _best practices: http://code.google.com/p/objectify-appengine/wiki/BestPractices

Limitations
-----------

One of the limitations of using Objectify is the lack of support for an abstract base class. The *Game* class should really be abstract and never directly instantiated, but adding the *abstract* keyword to the class definition causes a runtime exception to be thrown by Objectify. The exception essentially states that Objectify was unable to instantiate an abstract class without more specific type information. One possible workaround for this issue would be to simply remove the *@Entity* annotation from the abstract base class and place this annotation on each of the concrete subclasses. The disadvantages to this approach are that this will create a separate datastore kind for each of the subclasses and it requires an amount of code-repeat proportional to the amount of code in the abstract base class (since you have to override the member properties for Objectify to pick up on them).

While this workaround could have been implemented for TicTacToe, another limitation surrounding abstract base classes is introduced by using the Google Cloud Endpoints service. As evidenced by the *findOrCreateGame()* method of the *MatchmakingController* class, an abstract base class is useful because it can be used to return an object with a type corresponding to any of the concrete subclasses. However, because of how the endpoints tool generates the API client libraries and configuration files, the underlying type of the object returned by the *findOrCreateGame()* method will always be *Game*. When the client sends a *Game* object back to the API backend, it will have type *Game* and not one of the subclass types. If *Game* is abstract, this will cause the JSON serializer to throw an exception complaining about how it cannot serialize an abstract class.

Unfortunately, due to the limitations just mentioned, some nice Scala features like pattern matching cannot be utilized because the underlying type of a parameter with type *Game* will always be *Game*. While this doesn't severely affect the TicTacToe application, for a more complex application this lack of support might not be acceptable. Luckily, there will be support in the future for abstract base classes in Objectify, likely using an annotation such as *@EntityBase*. Once this support is released, the workaround mentioned in the Objectify section of the Techonologies page about having a separate internal and external representation could be used to workaround the issue introduced by Google Cloud Endpoints.