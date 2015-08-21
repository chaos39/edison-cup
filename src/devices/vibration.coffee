vibration = require 'jsupm_ldt0028'

# A piezo vibration sensor.
class Vibration
  # @param {Number} aioPort the asynchronous IO port that the vibration sensor
  #   is connected to
  constructor: (aioPort) ->
    @_vibration = new vibration.LDT0028 aioPort

  # @return {Number} the moisture reading; 0-300 means the sensor is in air or
  #   dry soil; 300-600 means the sensor is in humid soil; over 600 means the
  #   sensor is in wet soil or submerged in water
  value: ->
    @_vibration.getSample()


module.exports = Vibration
