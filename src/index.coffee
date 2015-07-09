require('es6-promise').polyfill()

Backend = require './backend.coffee'
Controller = require './controller.coffee'
Devices = require './devices.coffee'
LedBlinker = require './led_blinker.coffee'
LedLcdCoupler = require './led_lcd_coupler.coffee'
WebController = require './web_controller.coffee'

backend = new Backend()
devices = new Devices()
coupler = new LedLcdCoupler devices.lcd
blinkers =
  red: new LedBlinker coupler.ledWrapper(devices.redLed, 255, 0, 0)
  blue: new LedBlinker coupler.ledWrapper(devices.blueLed, 0, 0, 255)
  green: new LedBlinker coupler.ledWrapper(devices.greenLed, 0, 255, 0)
controller = new Controller backend, devices, blinkers
webController = new WebController backend, devices, blinkers

Promise.resolve(true)
    .then ->
      backend.initialize()
    .then ->
      devices.initialize()
    .then ->
      devices.lcd.info 'Initializing', 'Controller'
      controller.initialize()
    .then ->
      devices.lcd.info 'Initializing', 'Web controller'
      webController.initialize()
    .then ->
      controller.startSensing()
      controller.updateLcd()
    .catch (error) ->
      console.error "BACKEND INIT FAILED"
      console.error error.message
      console.error error.stack
      devices.lcd.error 'Booting', 'Failed'
      process.exit 1
