Acceleration = require './devices/acceleration.coffee'
Alcohol = require './devices/alcohol.coffee'
BtCount = require './devices/bt_count.coffee'
FakeLcd = require './devices/fake_lcd.coffee'
Gyro = require './devices/gyro.coffee'
InternalLed = require './devices/internal_led.coffee'
IpAddress = require './devices/ip_address.coffee'
Lcd = require './devices/lcd.coffee'
Led = require './devices/led.coffee'
Light = require './devices/light.coffee'
Loudness = require './devices/loudness.coffee'
Moisture = require './devices/moisture.coffee'
Motion = require './devices/motion.coffee'
Rotary = require './devices/rotary.coffee'
Temperature = require './devices/temperature.coffee'
Touch = require './devices/touch.coffee'
Water = require './devices/water.coffee'


# The device configuration for the board.
#
# This should be a singleton.
class Devices
  # @property {BtCount} the bluetooth device count virtual sensor
  btCount: null

  # @property {IpAddress} the IP address virtual sensor
  ipAddress: null

  # @property {Lcd} the LCD
  lcd: null

  # @property {Gyro} the gyroscope
  gyroscope: null

  # @property {Alcohol} the alcohol sensor
  alcohol: null

  # @property {Water} the water sensor
  water: null

  # @property {Temperature} the temperature sensor
  temperature: null

  # @property {Acceleration} the accelerometer sensor
  acceleration: null

  # @property {Light} the light sensor
  light: null

  # @property {Led} the red LED
  redLed: null

  # @property {Led} the blue LED
  blueLed: null

  # @property {InternalLed} the green internal LED
  greenLed: null

  constructor: ->
    # The Bluetooth sensor is virtual and just works.
    #@btCount = new BtCount()
    # The IP address sensor is virtual and just works.
    #@ipAddress = new IpAddress()
    # The LCD can be connected to any I2C port.
    #@lcd = new FakeLcd()  # Replace with Lcd() if you have a real Grove LCD.
    @lcd = new Lcd()
    # The accelerometer can be connected to any I2C port.
    #@acceleration = new Acceleration()
    # The gyroscope must be connected to AIO 2.
    #@gyroscope = new Gyro 2
    # The alcohol sensor must be connected to AIO 0 and uses up GPIO 15.
    #@alcohol = new Alcohol 0, 15
    # The touch sensor must be connected to D 5 and uses up GPIO 5.
    @touch = new Touch 5
    # The rotary sensor must be connected to AIO 2.
    #@rotary = new Rotary 2
    # The water sensor must be connected to D 4 and uses up GPIO 4.
    #@water = new Water 4
    # The temperature sensor must be connected to AIO 3.
    @temperature = new Temperature 3
    # The moisture sensor must be connected to AIO 3.
    #@moisture = new Moisture 3
    # The light sensor must be connected to AIO 1.
    @light = new Light 1
    # The loudness sensor must be connected to AIO 0.
    @loudness = new Loudness 0
    # The motion sensor must be connected to D 4 and uses up GPIO 4.
    @motion = new Motion 4
    # The red LED must be connected to D 2 and uses up GPIO 2.
    @redLed = new Led 2
    # The blue LED must be connected to D 3 and uses up GPIO 3.
    @blueLed = new Led 3
    # The internal LED is hardwired.
    @greenLed = new InternalLed

  # @return {Promise} resolved when all the hardware is initialized
  initialize: ->
    @lcd.clear()
    @lcd.info 'LCD', 'Initialized'

    Promise.resolve(true)
        .then =>
          @lcd.info 'Calibrating', 'Gyroscope'
          if @gyroscope
            @gyroscope.initialize()
          else
            true
        .then =>
          if @alcohol
            @lcd.info 'Heating', 'Breathalizer'
            @alcohol.initialize(true)  # skipHeating is true
        .then =>
          @lcd.info 'Hardware', 'Ready'

  # Obtains readings from all the sensors.
  #
  # @return {Object} readings from all the sensors
  sensors: ->
    {
      #alcohol: @alcohol.value()
      #btCount: @btCount.value()
      #gravityX: @acceleration.valueX()
      #gravityY: @acceleration.valueY()
      #gravityZ: @acceleration.valueZ()
      #gyroscope: @gyroscope.value()
      #ipAddress: @ipAddress.value()
      light: @light.value()
      loudness: @loudness.value()
      motion: @motion.value()
      #moisture: @moisture.value()
      #rotary: @rotary.value()
      temperature: @temperature.value()
      touch: @touch.value()
      #water: @water.value()
    }


module.exports = Devices
