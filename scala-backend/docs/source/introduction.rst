=============
Introduction
=============

This documentation is in support of the TicTacToe application, which consists of a Google App Engine backend written in Scala and Java and an iOS client application. The documentation assumes that you are already familiar with using Google App Engine and Apache Ant with Scala and Java. If you need a refresher, take a look at `the documentation`_ and `code`_ for my previous tutorial on these topics.

.. _the documentation: https://scalaongae.readthedocs.org/en/latest/
.. _code: https://github.com/choruk/scala-gae

The intent of this documentation is to provide an in-depth explanation of how you can use Google App Engine to host a Scala backend that uses the Google Cloud Endpoints service to provide a uniform set of APIs accessible from web, Android and iOS clients. The sample application itself only implements the iOS client, but the Scala backend can support Android or web clients as well. Another intent of the documentation is to discuss the use of the Objectify framework to interact with the AppEngine datastore and address any caveats with its interaction with the Google Cloud Endpoints service.

The documentation is structured to first introduce you to the various technologies used by the TicTacToe application along with any configurations necessary to use them within TicTacToe. You are then provided with a high level description of the implementation of the complete TicTacToe application. Finally, there are multiple sections on the application code, one for each major portion of the code, that further explain any required configurations and encountered limitations.