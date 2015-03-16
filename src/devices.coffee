Alcohol = require './devices/alcohol.coffee'
Gyro = require './devices/gyro.coffee'
InternalLed = require './devices/internal_led.coffee'
Led = require './devices/led.coffee'
Lcd = require './devices/lcd.coffee'
Touch = require './devices/touch.coffee'
Water = require './devices/water.coffee'


# The device configuration for the board.
#
# This should be a singleton.
class Devices
  # @property {Lcd} the LCD
  lcd: null

  # @property {Gyro} the gyroscope
  gyro: null

  # @property {Alcohol} the alcohol sensor
  alcohol: null

  # @property {Water} the water sensor
  water: null

  # @property {Led} the red LED
  redLed: null

  # @property {Led} the blue LED
  blueLed: null

  # @property {InternalLed} the green internal LED
  greenLed: null

  constructor: ->
    # The LCD can be connected to any I2C port.
    @lcd = new Lcd
    # The gyroscope must be connected to AIO 3.
    @gyroscope = new Gyro 3
    # The alcohol sensor must be connected to AIO 0 and uses up GPIO 15.
    @alcohol = new Alcohol 0, 15
    # The touch sensor must be connected to D 8 and uses up GPIO 8.
    @touch = new Touch 8
    # The water sensor must be connected to D 4 and uses up GPIO 4.
    @water = new Water 4
    # The red LED must be connected to D 2 and uses up GPIO 2.
    @redLed = new Led 2
    # The blue LED must be connected to D 3 and uses up GPIO 3.
    @blueLed = new Led 3
    # The internal LED is hardwired.
    @greenLed = new InternalLed

  # @return {Promise} resolved when all the hardware is initialized
  initialize: ->
    @lcd.clear()
    @lcd.info 'LCD Initialized'

    @lcd.info 'Calibrating', 'Gyroscope'
    @gyroscope.initialize()
      .then =>
        @lcd.info 'Heating', 'Breathalizer'
        @alcohol.initialize()
      .then =>
        @lcd.info 'Hardware', 'Ready'

  # Obtains readings from all the sensors.
  #
  # @return {Object} readings from all the sensors
  sensors: ->
    {
      alcohol: @alcohol.value()
      gyroscope: @gyroscope.value()
      touch: @touch.value()
      water: @water.value()
    }


module.exports = Devices
