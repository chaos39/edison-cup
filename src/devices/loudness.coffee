grove = require 'jsupm_groveloudness'

# A grove loudness sensor.
class Loudness
  # @param {Number} aioPort the asynchronous IO port that the loudness sensor
  #   is connected to
  constructor: (aioPort) ->
    @_grove = new grove.GroveLoudness aioPort

  # @return {Number} loudness
  value: ->
    @_grove.value()


module.exports = Loudness
