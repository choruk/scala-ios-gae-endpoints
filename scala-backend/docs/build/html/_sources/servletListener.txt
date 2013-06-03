=============================
The Servlet Context Listener
=============================

A common need of many applications is the ability to execute some operations when the application is initialized. With Google App Engine, this need is satisfied through three different approaches: a <load-on-startup> servlet, a ServletContextListener, or a custom warmup servlet. Google's documentation on `warmup requests`_ already covers the basics of these three approaches.

.. _warmup requests: https://developers.google.com/appengine/docs/java/config/appconfig#Warmup_Requests

TicTacToe needs to use a servlet context listener for two reasons: to register the datastore entities with Objectify and to initialize the application's global logger. The first reason is simply a requirement by Objectify and because it should only run once before all other servlet code, it fits nicely into the servlet context listener. The second reason is to ensure that the application's logs correctly reflect all of the messages logged within the application's code.

One important fact to remember about a ServletContextListener is that it might be invoked as part of the first user request to your application if no warmup request was initiated, which will result in loading requests. If you have some complex logic being handled within a ServletContextListener, your application will incur additional load time, which might not make your users too happy.