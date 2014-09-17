# WavHead: Vote on Music

### What is this?
A simple program to let people vote on music. Essentially, you run a local
server which lists music. People vote on what they want to listen to, and it
plays songs in order of votes.

### How do I use it?

The usage is very simple. Run ````wav_head -i DIRECTORY```` to index a
directory (By default, ````~/Music/````). Run ````wav_head -s```` to start a
server. Optionally, set the port with ````wav_head -p PORT````. Navigate any
browser to your hostname and port, and start playing some tunes!

If you ever need to delete the index of songs, just run ````wav_head -d````. For
a pretty-printed output of indexed songs, just use ````wav_head -l````.

More features to follow.

Licensed under the BSD License.
