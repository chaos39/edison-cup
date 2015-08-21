mraa = require 'mraa'

# Generic code that reports the data from a GPIO port.
class RawGpio
  # @param {Number} dPort the D port that the sensor is connected to
  constructor: (dPort) ->
    @_gpio = new mraa.Gpio dPort
    @_gpio.dir mraa.DIR_IN

  # @return {Number} loudness
  value: ->
    @_gpio.read()


module.exports = RawGpio
