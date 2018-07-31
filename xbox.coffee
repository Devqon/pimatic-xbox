module.exports = (env) ->

  Promise = env.require 'bluebird'
  commons = require('pimatic-plugin-commons')(env)
  xboxOneApi = require('./xbox-one-api')(env)

  class XboxPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./xbox-device-config-schema")

      xboxPowerSwitchConfig = deviceConfigDef.XboxPowerSwitch
      xboxPowerSwitchConfig.properties.ip.default = @config.ip
      xboxPowerSwitchConfig.properties.liveId.default = @config.liveId
      xboxPowerSwitchConfig.properties.type.default = @config.type

      @framework.deviceManager.registerDeviceClass("XboxPowerSwitch", {
        configDef: xboxPowerSwitchConfig,
        createCallback: (config) => new XboxPowerSwitch(config)
      })

  class XboxPowerSwitch extends env.devices.PowerSwitch
    constructor: (@config) ->
      @_base = commons.base @, @config.class
      @name = @config.name
      @id = @config.id
      if @config.type is "xbox-one"
        @_base.debug "Initializing xbox with host #{@config.host} and live id #{@config.liveId}"
        @api = new xboxOneApi(@config)
      else
        @api = null
        @_base.error "Only xbox-one is supported for now"
      @_state = false
      super()

    changeStateTo: (state) ->
      return new Promise (resolve, reject) => 
        if state
          @_base.debug "Trying to power the xbox #{@xbox.id} #{@xbox.ip}"
          @api.powerOn().then =>
            @_setState(true)
            resolve()
          .catch =>
            reject()
        else
          @api.powerOff().then =>
            _setState(false)
            resolve()

    getState: () ->
      return Promise.resolve @_state

    destroy: () ->
      @_base.cancelUpdate()
      @api.destroy()
      super()

  # ###Finally
  # Create a instance of my plugin
  xboxPlugin = new XboxPlugin
  # and return it to the framework.
  return xboxPlugin