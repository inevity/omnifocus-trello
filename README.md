# omnifocus-trello

code: https://github.com/vesan/omnifocus-trello

Plugin for omnifocus gem to provide Trello BTS synchronization.

Pulls all cards assigned to a user and creates corresponding tasks to OmniFocus.
Cards in lists having completed cards are marked as done. The user whose tasks
are synced and the lists that are considered as having completed cards are
configurable using the config file.

Now some features and change log since v1.2.2 
1. change to use bug_db hash from array
2. use label red as flagged in of
3. use label green as nested tag "When : Today" in of  
   ref: https://inside.omnifocus.com/blog/the-forecast-tag.
4. use due as due_date in of
5. update of task once trello care have been updated according
   card field dateLastActivity.  
6. update depency omnifocus to 2.4 and add as submodule

todos:  
1. defer date maybe use the powerup feature.
2. two-way sync.

## Usage

1. Install

    $ gem install omnifocus-trello

2. Sync

    $ of sync

3. (On the first run, configuration file will be generated at
   ~/.omnifocus-trello.yml. Follow to instructions to get a token.)

# Changing the default Folder for trello boards.

By default, the OmniFocus projects created from your trello boards will be stored in a folder called "nerd". To change this, set an environment variable called 'OF_FOLDER'. You can do this by adding the following to your `bash_profile` or similar:

    export OF_FOLDER="My Trello Boards"

Note that this environment variable is used by the [omnifocus](https://github.com/seattlerb/omnifocus) gem, so will apply to any other gems that rely on that.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
