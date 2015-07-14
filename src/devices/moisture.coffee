moisture = require 'jsupm_grovemoisture'

# A moisture sensor.
class Moisture
  # @param {Number} aioPort the asynchronous IO port that the moisture sensor
  #   is connected to
  constructor: (aioPort) ->
    @_moisture = new moisture.GroveMoisture aioPort

  # @return {Number} the moisture reading; 0-300 means the sensor is in air or
  #   dry soil; 300-600 means the sensor is in humid soil; over 600 means the
  #   sensor is in wet soil or submerged in water
  value: ->
    @_moisture.value()


module.exports = Moisture
