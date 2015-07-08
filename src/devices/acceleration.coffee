Adxl345 = require 'jsupm_adxl345'

class Acceleration
  constructor: ->
    @_accelerometer = new Adxl345.Adxl345 0
    @_lastVector = [0, 0, 0]

  # Get the proper acceleration along the X axis.
  #
  # @return {Number} the force in g/second
  valueX: ->
    @_accelerometer.update()
    vector = @_accelerometer.getAcceleration()
    @_lastVector = (vector.getitem(i) for i in [0, 1, 2])
    @_lastVector[0]

  # Get the proper acceleration along the Y axis.
  #
  # @return {Number} the force in g/second
  valueY: ->
    @_lastVector[1]

  # Get the proper acceleration along the Z axis.
  #
  # @return {Number} the force in g/second
  valueZ: ->
    @_lastVector[2]


module.exports = Acceleration
