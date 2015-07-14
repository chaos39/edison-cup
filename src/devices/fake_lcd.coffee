# Simulates the Lcd module, but prints out to screen.
class FakeLcd
  # Output an informational progress message.
  info: (line1, line2) ->
    @write line1, line2, 255, 255, 255

  # Output an alert that the user should notice.
  alert: (line1, line2) ->
    @write line1, line2, 255, 255, 0

  # Output an alert message.
  error: (line1, line2) ->
    @write line1, line2, 255, 0, 0

  # Sets up the LCD.
  constructor: ->
    @_lineSize = 16
    @_red = null
    @_green = null
    @_blue = null


  # Sets the LCD's background color.
  #
  # The LCD's color is cached, and only modified when necessary.
  #
  # @param {Number} red 0-255
  # @param {Number} green 0-255
  # @param {Number} blue 0-255
  # @return undefined
  setBackground: (red, green, blue) ->
    return if @_red is red and @_green is green and @_blue is blue
    @_red = red
    @_green = green
    @_blue = blue
    return

  # Returns the LCD's current background color.
  #
  # @return {Array<Number>} an array of the 3 background colors
  getBackground: ->
    [@_red, @_green, @_blue]

  # Writes an LCD message to the LCD.
  #
  # @return undefined
  write: (line1, line2, red, green, blue) ->
    @setBackground red, green, blue

    line1 = @_fixLine line1
    line2 = @_fixLine line2

    console.log "#{line1} #{line2}"
    return

  # Return a string that matches the line size precisely.
  _fixLine: (line) ->
    line = '' if line is undefined or line is null
    if line.length < @_lineSize
      line += (new Array(@_lineSize - line.length + 1)).join ' '
    else if line.length > @_lineSize
      line = line.substring 0, 16

  # Clears the LCD.
  #
  # @return undefined
  clear: ->
    return

module.exports = FakeLcd
