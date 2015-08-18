grove = require 'jsupm_biss0001'

# A grove loudness sensor.
class Motion
  # @param {Number} dPort the D port that the motion sensor connected to
  constructor: (dPort) ->
    @_grove = new grove.BISS0001 dPort

  # @return {Number} 1 if the sensor detects motion, -1 otherwise
  value: ->
    if @_grove.value() > 0 then 1 else -1

module.exports = Motion
