errorHandler = require 'errorhandler'
express = require 'express'

# The Web debugging front-end.
#
# This can be used to debug the board's sensors without a backend.
class WebController
  constructor: (backend, devices, blinkers) ->
    @_backend = backend
    @_devices = devices
    @_blinkers = blinkers
    @_initPromise = null
    @_port =  process.env.PORT || 8010

    @_app = express()
    @_app.use errorHandler()
    @_app.get '/hello', @_onHello.bind(@)
    @_app.get '/s/:sensor', @_onSensor.bind(@)
    @_app.get '/blink', @_onBlink.bind(@)
    @_app.get '/lcd', @_onLcd.bind(@)
    @_app.get '/uuids', @_onUuids.bind(@)

  # Starts the Web front-end.
  #
  # @return {Promise} resolved when the server is started up
  initialize: ->
    return @_initPromise unless @_initPromise is null

    @_initPromise = new Promise (resolve, reject) =>
      @_app.listen @_port, ->
        resolve true

  # GET /hello
  _onHello: (request, response) ->
    response.json message: 'Ohai from CoffeeScript'

  # GET /s/sensor
  _onSensor: (request, response) ->
    sensor = request.params.sensor
    if sensor of @_devices
      value = @_devices[sensor].value()
    else
      value = 'missing sensor'
    response.json value: value

  # GET /blink?color=green&seconds=3
  _onBlink: (request, response) ->
    color = request.params.color || request.query.color
    seconds = parseInt request.params.seconds || request.query.seconds
    if color of @_blinkers
      @_blinkers[color].blinkFor seconds
      value = 'ok'
    else
      value = 'missing LED'
    response.json value: value

  # GET /lcd?color=FF00FF&line1=Hello&line2=World
  _onLcd: (request, response) ->
    hexColor = request.params.color || request.query.color || '0000ff'
    line1 = request.params.line1 || request.query.line1 || ''
    line2 = request.params.line2 || request.query.line2 || ''
    if hexColor
      red = parseInt hexColor.substring(0, 2), 16
      green = parseInt hexColor.substring(2, 4), 16
      blue = parseInt hexColor.substring(4, 6), 16
    else
      [red, green, blue] = [0, 0, 255]

    @_devices.lcd.write line1, line2, red, green, blue
    response.json value: 'ok'

  # GET /uuids
  _onUuids: (request, response) ->
    uuids = Object.keys @_devices.btCount._devices
    response.json uuids: uuids


module.exports = WebController
