# Dumb-bot

First attempt at writing a bot to play the CoEngine game via the SimpleApi interface. 

This is a general hack around to see if the game engine worked as expected and to fix any bugs encountered
along the way.

At this stage the code is mostly untested and is designed to help figure our what a bot does and does not need to do.
With the plan to build more advance bots around the core code, with configuration options so that different difficulty 
levels can be played at.

Happy to have other add their own bots - please be aware the API is subject to change.

Bots can either be implemented in the bots directory, or as seperate gems which are loaded at runtime backed on the bots.yml configuration.
