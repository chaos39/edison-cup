moment = require 'moment-timezone'

# Shuttles data around between the backend and the sensors.
class Controller
  constructor: (backend, devices, blinkers, twitter) ->
    @_backend = backend
    @_devices = devices
    @_blinkers = blinkers
    @_twitter = twitter
    @_senseInterval = 1000
    @_senseIntervalHandler = null
    @_minDeltas = { temperature: 3 }
    @_oldSensors = {}

  # Initializes the controller, after the backend and devices are set up.
  #
  # @return {Promise<Boolean>} resolves to true when the controller is
  #   initialized
  initialize: ->
    # NOTE: Push notifications can be disabled if WebSockets are blocked
    if @_backend.pushRegistration
      @_backend.pushRegistration.onpush = @_onPush.bind(@)

  # @return {Boolean} true if the controller's sensing loop is running
  startedSensing: ->
    @_senseIntervalHandler isnt null

  # Starts the sensing loop.
  #
  # @return undefined
  startSensing: ->
    return if @startedSensing()

    callback = =>
      return unless @startedSensing()
      @_onSenseInterval()
      return
    @_senseIntervalHandler = setInterval callback, @_senseInterval

  # Updates the LCD message to reflect the current board's identity.
  updateLcd: ->
    if @_backend.config.setverUrl
      if @_backend.config.identity.code
        code = @_backend.config.identity.code.replace(/\w{3}/g, "$& ")
        @_devices.lcd.alert 'Board code', code
      else
        @_devices.lcd.info 'Registered', @_backend.config.identity.name
    else
      @_devices.lcd.info 'Device', 'Ready'

  # Stops the sensing loop, if it was started.
  #
  # @return undefined
  stopSensing: ->
    return unless @startedSensing()
    cancelInterval @_senseIntervalHandler
    @_senseIntervalHandler = null
    return

  # One iteration of the sensing loop.
  #
  # @return undefined
  _onSenseInterval: ->
    newSensors = @_devices.sensors()
    sensorsDiff = @_sensorsDiff @_oldSensors, newSensors
    return if sensorsDiff is null
    if @_backend.config.serverUrl
      @_backend.client.updateSensors(sensorsDiff)
    if timeZone = @_twitter.config('timezone')
      timePrefix = moment().tz(timeZone).format("ddd h:mm a")
      if 'water' of sensorsDiff
        if sensorsDiff.water is -1
          @_twitter.tweet(timePrefix +
              " - I am out of water. Please help me!")
        else if sensorsDiff.water is 1
          @_twitter.tweet "#{timePrefix} - I now have water. Thank you!"

      if 'temperature' of sensorsDiff
        temperature = sensorsDiff.temperature
        @_twitter.tweet(timePrefix +
            " - My surrounding temperature is now #{temperature} C.")

    return

  # Computes the difference between two sensor readings.
  #
  # @param {Object<String, Number|String>} oldSensors the old sensor readings
  # @param {Object<String, Number|String>} newSensors the new sensor readings
  # @return {Object?<String, Number|String>} an object that only has properties
  #   for the new sensor readings; nil if the readings show no difference
  _sensorsDiff: (oldSensors, newSensors) ->
    diff = null
    for name, value of newSensors
      oldValue = oldSensors[name]
      continue if oldValue is value
      unless typeof oldValue is 'undefined'
        delta = Math.abs(value - oldValue)
        continue if (minDelta = @_minDeltas[name]) && (delta < minDelta)

      diff = {} if diff is null
      diff[name] = value
      oldSensors[name] = value
    diff

  # Called when a push notification is received.
  _onPush: (event) ->
    try
      data = JSON.parse event.data
    catch jsonError
      return
    switch data.cmd
      when 'reload'
        @_backend.reloadIdentity().then =>
          @updateLcd()
      when 'blink'
        if data.color of @_blinkers
          @_blinkers[data.color].blinkFor data.seconds
      when 'lcd'
        hexColor = data.color
        red = parseInt hexColor.substring(0, 2), 16
        green = parseInt hexColor.substring(2, 4), 16
        blue = parseInt hexColor.substring(4, 6), 16
        @_devices.lcd.write data.line1, data.line2, red, green, blue
    return


module.exports = Controller
