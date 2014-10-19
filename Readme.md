# WavHead: Vote on Music
![A screen shot. Not terribly important.]()
### What is this?
A simple program to let people vote on music. Essentially, you run a local
server which lists music. People vote on what they want to listen to, and it
plays songs in order of votes.


### How do I use it?

First off, clone the repository. Navigate to the folder created in a termainl,
and type "bundle install". You'll need to install TagLib, which is easily done
on most Linux distros and on OSX with homebrew - it should output instructions
on how to do so when you run "bundle install". 

After that's done, you'll need to index some music. This lets WavHead know that
your music exists. Run ````./wav_head.rb -i $(DIRECTORY)```` to do that. If you
do not supply a directory, it will look in ````~/Music/````.

After that's done, you'll probably want to start up a server. Run
````./wav_head.rb -s```` to do that, optionally setting the port with the 
-p flag. Now, users can vote on music by navigating to your computer with
their browser.

#### Wait a minute. What url should they visit?

Well, they'll need to go to your computer's hostname. Thankfully, finding
out what that is is easy: type ````hostname```` in a terminal, and bam,
you're ready to go. They'll also need to go to the right port, so simply
append a ":" and the port number (by default, 4567) to your hostname and you're
good to go.

### Does this work on Windows?

It's not officially supported, but with a bit of wizardry you can probably
get it working.


