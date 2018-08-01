module.exports = (env) ->

  Promise = env.require 'bluebird'
  commons = require('pimatic-plugin-commons')(env)
  xboxOneApi = require('./xbox-one-api')(env)

  class XboxPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./xbox-device-config-schema")

      xboxPowerSwitchConfig = deviceConfigDef.XboxPowerSwitch
      xboxPowerSwitchConfig.properties.host.default = @config.host
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
        @_base.error "Xbox type #{@config.type} is not supported"
      
      @_state = false

      super(@config)

    changeStateTo: (state) ->
      return new Promise (resolve, reject) => 
        if state
          @_base.debug "Trying to power the xbox #{@config.host} #{@config.ip}"
          @api.powerOn().then =>
            @_setState(true)
            resolve()
          .catch =>
            reject()
        else
          @api.powerOff().then =>
            @_setState(false)
            resolve()

    getState: () ->
      return Promise.resolve @_state

    destroy: () ->
      @_base.cancelUpdate()
      @api.destroy()
      super()

  xboxPlugin = new XboxPlugin

  return xboxPlugin