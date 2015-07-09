class LedLcdCoupler
  constructor: (lcd) ->
    @_lcd = lcd
    @_background = null
    @_wrappers = []

  # Wraps an LED.
  #
  # @param {Led} led the LED to be wrapped
  # @param {Number} red the red component of the LCD display's background color
  # @param {Number} green the green component of the LCD display's background
  #   color
  # @param {Number} blue the blue component of the LCD display's background
  #   color
  # @return {LedWrapper} the newly created LED wrapper
  ledWrapper: (led, red, green, blue) ->
    wrapper = new LedWrapper @, led, red, green, blue
    @_wrappers.push wrapper
    wrapper

  # Called when an LED is turned off or on.
  onLedChange: ->
    if @_background is null
      @_background = @_lcd.getBackground()

    for wrapper in @_wrappers
      if wrapper.isSet()
        @_lcd.setBackground wrapper.red, wrapper.green, wrapper.blue
        return

    @_lcd.setBackground @_background[0], @_background[1], @_background[2]
    @_background = null

class LedWrapper
  constructor: (coupler, led, red, green, blue) ->
    @_coupler = coupler
    @_led = led
    @red = red
    @green = green
    @blue = blue

  # Wraps {Led#set}.
  set: (lightOn) ->
    @_led.set lightOn
    @_coupler.onLedChange()

  # Wraps {Led#isSet}.
  isSet: ->
    @_led.isSet()


module.exports = LedLcdCoupler
