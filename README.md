# Teamwork::InstaHours

A rapidly growing utility to check hours in Teamwork and automatically complete week by submitting your missing hours to a default project.
Useful for folks like me that work primarily on a single support project

# What it Does
* Allows you to see time entries and total hours for a given week
* Allows you to configure a list of favorite projects with a code => id
* Allows you to add hours to favorite projects with a very simple format
* Allows you to generate all missing time and apply it to a given default project.
* Allows you to run an interactive script that confirms your information and asks you what you want to do
* [NEW] Allows you to get all your tasks and github commits for the week or past week

For instance: You look up your weekly hours and you see you logged 30 minutes of work on some project on Tuesday and an hour and half to some other project on Wednesday. Fire of the 'complete' command and InstaHours will add 8 hours to your default project on days without any entries, 7 1/2 hours on Tuesday and 6 1/2 hours on Wednesday.

You now have all 40 hours accounted for.

And if you don't want to have to take the time looking up what hours you have already logged, just use the command line tool. It will let you know the state of things before asking you if you want to complete the week's entries automatically.

You can also ask it to show you all the tasks you have hours applied to and a list of all your github commits for your primary project across all branches.

# Requirements:
  * enable TW api key in your account
  * set Env variables on your puter: TW_API_KEY,  GITHUB_PWD (if using InstaTime)
  * include this class in a script
  * highline gem for interactive script

# Configuration:
* there is a yaml file that contains all the none-private information needed like user ids and project ids. Just add your specific information to it.

# RUNNERS

ruby instarun.rb hours

* Confirm your identity and your default project
* Allow you to choose a different week to work with
* Give you a look at the current entries already logged
* Ask you if you want to complete the weeks entries by submitting any missing time to your default project
* Can show you a list of favorite projects and allow you to add hours to them
* Open up Teamwork website

ruby instarun.rb time

* Confirm your identity and your default project
* Allow you to choose a different week to work with
* Give you a look at the current tasks and commits you have made
* Open up Teamwork website
