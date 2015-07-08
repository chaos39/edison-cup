W3gram = require 'w3gram'

Client = require './backend/client.coffee'
Config = require './backend/config.coffee'


# All the backend functionality.
class Backend
  # @property {Promise<Boolean}> resolves to true when the backend Web service
  #   is initialized and all properties are set to valid values
  ready: null

  # @property {Config} the backend configuration
  config: null

  # @property {Client} client for the backend Web service
  client: null

  # @property {W3Gram.PushRegistrationManager} client for the push service
  pushManager: null

  constructor: ->
    @config = new Config()
    @client = null
    @pushManager = null
    @pushRegistration = null
    @_resolveReady = null
    @_rejectReady = null
    @ready = new Promise (resolve, reject) =>
      @_resolveReady = resolve
      @_rejectReady = reject

  # Sets up all the backend structures.
  #
  # @return {Promise<Boolean>} resolved with true when the backend structures
  #   are configured
  initialize: ->
    if @_resolveReady is null
      return @_ready

    @config.initialize()
      .then =>
        @client = new Client @config
        @_setIdentity()
      .then =>
        @client.setIdentity @config.identity
      .then =>
        identity = @config.identity
        return true unless identity.push
        @pushManager = new W3gram.PushRegistrationManager identity.push
        @pushManager.register()
      .then (pushRegistration) =>
        return true unless @config.identity.push
        @pushRegistration = pushRegistration
        @client.updatePushInfo pushRegistration
      .then =>
        @_resolveReady true
        @_resolveReady = null
        @_rejectReady = null
      .catch (error) =>
        @_rejectReady error
        @_resolveReady = null
        @_rejectReady = null
    @ready

  # Reloads the board's identity from the backend server.
  #
  # @return {Promise<Boolean>} resolved to true when this board is guaranteed
  #   to have a fresh identity
  reloadIdentity: ->
    @_setIdentity()

  # Creates or updates this board's identity.
  #
  # @return {Promise<Boolean>} resolved to true when this board is guaranteed
  #   to have a fresh identity
  _setIdentity: ->
    identityPromise = if @config.identity
      @client.setIdentity @config.identity
      @client.reloadIdentity()
    else
      @client.register()

    identityPromise.then (identity) =>
      # NOTE: setIdentity returns a promise that resolves to true.
      @config.setIdentity identity

module.exports = Backend
