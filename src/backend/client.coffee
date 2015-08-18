request = require 'request'

# Client for the main backend server.
class Client
  # @param {Config} config the backend configuration
  constructor: (config) ->
    @_serverUrl = config.serverUrl
    @_serial = config.serial
    @_key = null

  # Creates an identity for this board.
  #
  # @return {Promise<Object>} resolved with the board's identity
  register: ->
    params = board:
        node_version: process.versions.node
        serial: @_serial
    @_jsonRequest 'POST', "#{@_serverUrl}/boards.json", params

  # Plugs this board's identity into the client.
  #
  # @param {Object} identity this board's identity
  # @return undefined
  setIdentity: (identity) ->
    @_key = identity.key
    return

  # Reloads the details of the board's identity from the server.
  #
  # @return {Promise<Object>} resolved with the board's identity
  reloadIdentity: ->
    @_jsonRequest('GET', "#{@_serverUrl}/boards/#{@_key}.json")

  # Sends this board's push registration to the backend server.
  #
  # @param {W3gram.PushRegistration} registration the board's push
  #   registration
  # @return {Promise<Boolean>} resolved with true
  updatePushInfo: (registration) ->
    url = "#{@_serverUrl}/boards/#{@_key}.json"
    params = board:
        push_url: registration.endpoint
    @_jsonRequest('PATCH', url, params).then =>
      true

  # Sends this board's sensor information to the backend server.
  #
  # @param {Object} sensors sensor data to be sent to the backend
  # @param {Number} boardTime the reading time to be sent to the backend
  # @return {Promise<Object>} resolves to the backend's reaction to the sensor
  #   information
  updateSensors: (sensors, boardTime) ->
    url = "#{@_serverUrl}/boards/#{@_key}/sensors.json"
    @_jsonRequest('PUT', url, sensors: sensors, board_time: boardTime)

  # Issues a generic JSON request to the backend.
  #
  # @param {String} method the HTTP method (e.g., "GET")
  # @param {String} url the URL to send the request to
  # @param {Object?} json the JSON object to be sent as the request body; null
  #   if no object should be sent
  # @return {Promise<Object>} resolved with the backend's response
  _jsonRequest: (method, url, json, callback) ->
    new Promise (resolve, reject) =>
      options =
        method: method
        url: url
        headers:
          accept: 'application/json'
      if json is null
        unless method is 'GET'
          options.headers['content-type'] = 'text/plain'
          options.body = ''
      else
        options.headers['content-type'] = 'application/json'
        options.body = JSON.stringify json

      request options, (error, response, body) =>
        if error
          reject error
          return
        if response.code < 200 || response.code >= 400
          reject new Error("Server returned HTTP error code #{response.code}")
          return
        try
          data = JSON.parse body
        catch jsonError
          reject jsonError
        resolve data

module.exports = Client
