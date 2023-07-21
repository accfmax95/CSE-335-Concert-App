# CSE-335-Concert-App

My project is an IOS application that presents a user with all of the local concerts in their area. 
A user has the option to sign-up, view the list of concerts that have been detected in their area, and save 
those concerts for future viewing. If the user decides to view their saved concert list, they will have the 
option to remove specific concerts, or click on a concert for more details, which will give them the option 
to search for a list of options on how to purchase tickets for that specific show.

This application is a tight and compact way to view and learn about upcoming music events in any person’s area,
and its simple nature allows for maximum ease of use. Any person can use the application, find a show, and be 
redirected to purchase options for that show in only a couple of minutes, which I believe is the application's
main selling feature.

The application had many functionalities worth mentioning. The first being the Firebase realtime database. 
This database stores individual users, as well as the information unique to their account, such as their email 
address, password, profile picture, and list of saved concerts. New registers can sign up using the app’s 
homepage, and each new user will be registered with the database. The database will be updated in realitime, 
so any adjustments made to the account will be put in place immediately. Also, I should mention that all this 
information is stored permanently, so if the app closes or goes without use for a period of time, all the 
information stored on an account will be saved whenever the user chooses to access it.

The functionality for the concert listing was built from two APIs: Telize geolocation API and the Concerts 
Event Tracker API. The Telize geo location grabs the current location of where the phone is located (specifically 
the latitude and longitude) and saves that information to the application. This is important because the concerts 
event tracker API requires a location to pull the concert data. Once the location has been specified to the
concerts API, the API sends a list of all concert information in that area. The list of events is displayed on a 
tableview, where the concert’s name, description, and image are displayed. The list of events it can display is 
theoretically infinite, but for the sake of the application, I chose to display the first 50 events, which on 
average displays the list of events for the next two months, which I thought was plenty sufficient.

A user can choose to save their concert for later viewing, which means that concert will be added to a dictionary 
that will be saved to the database. This dictionary creates a permanent list of all these events. The user can also 
access their profile, which gives them the option to update their email and password, change their profile picture, 
or log out–which will sign out the current user and unwind them back to the homepage. From the profile, they can also 
choose to access their saved concerts.

In their saved concerts list they have the option to delete any concert of their choosing by swiping left, or they 
can click on a concert to receive detailed information. Since all the details given by the API were used in the 
Tableview, I chose to present more information by coding a line that opens a Google search of the concert description 
along with the word “tickets,” so in every instance it should present a number of options on how to purchase tickets for this event.
