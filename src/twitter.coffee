fs = require 'fs'
path = require 'path'
TwitterClient = require 'twitter'

# Hacked up twitter client for one hardwired token.
#
# To use, write the following in ~/.edison_cup/twitter.json:
#
# {
#   "key": "twitter API key",
#   "secret": "twitter API secret",
#   "timezone": "America/New_York",
#   "token_key": "twitter access token key",
#   "token_secret": "twitter access token secret"
# }
class Twitter
  constructor: ->
    @_configDir = path.join process.env['HOME'], '.edison-cup'
    @_configFile = path.join @_configDir, 'twitter.json'
    @_config = null
    @_client = null

  # @return {Promise<Boolean>} resolved when the Twitter client is initialized
  initialize: ->
    @_ensureDirExists()
        .then =>
          @_loadApiKey()
        .then =>
          @_buildTwitterClient()

  # Retrieves a configuration key.
  #
  # @param {String} key the configuration key to be retrieved
  # @return {String} the configuration value
  config: (key) ->
    return null if @_config is null
    @_config[key]

  # Makes sure that the configuration directory exists.
  #
  # @return {Promise<Boolean>} resolved with true when the configuration
  #   directory is guaranteed to exist
  _ensureDirExists: ->
    new Promise (resolve, reject) =>
      fs.exists @_configDir, (exists) =>
        if exists
          resolve true
          return
        fs.mkdir @_configDir, (error) =>
          if error
            reject error
            return
          resolve true


  # Loads the Twitter API key from a JSON file.
  #
  # @return {Promise} resolved when the API keys are loaded.
  _loadApiKey: ->
    new Promise (resolve, reject) =>
      fs.readFile @_configFile, encoding: 'utf8', (error, jsonText) =>
        if error
          # NOTE: We proceed even if there's no twitter account.
          resolve true
          return
        try
          @_config = JSON.parse jsonText
          resolve true
        catch jsonError
          reject jsonError

  # Sets up the Twitter client instance variable.
  _buildTwitterClient: ->
    if @_config is null
      @_client = null
      return
    @_client = new TwitterClient(
        consumer_key: @_config.key,
        consumer_secret: @_config.secret,
        access_token_key: @_config.token_key,
        access_token_secret: @_config.token_secret)
    true


  # Posts a tweet to the Twitter account associated with the API key.
  #
  # @param {String} statusText the contents of the tweet
  # @return {Promise} resolved when the tweet is posted
  tweet: (statusText) ->
    if @_client is null
      return Promise.reject(new Error("Twitter client not set up"))

    new Promise (resolve, reject) =>
      @_client.post 'statuses/update', status: statusText,
          (error, tweet, response) =>
            if error
              reject error
              return
            resolve tweet


module.exports = Twitter
