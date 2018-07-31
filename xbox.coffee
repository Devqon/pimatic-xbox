module.exports = (env) ->

  Promise = env.require 'bluebird'
  commons = require('pimatic-plugin-commons')(env)
  xbox = require 'xbox-on'

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
        @_base.debug "Initializing xbox with ip #{@config.ip} and live id #{@config.liveId}"
        @xbox = new xbox(@config.ip, @config.liveId)
      else
        @xbox = null
        @_base.error "Only xbox-one is supported for now"
      @_state = false
      super()

    changeStateTo: (state) ->
      return new Promise (resolve, reject) => 
        if state
          @_base.debug "Trying to power the xbox #{@xbox.id} #{@xbox.ip}"
          options = {
            tries: 5,
            delay: 1000,
            waitForCallback: true
          }
          @xbox.sendOn((err) =>
            if err
              @_base.rejectWithErrorString reject, if err instanceof Error then err else "Could not turn on xbox"
            else
              @_base.info "Xbox powered on"
              # set state false anyway, because there is no implementation for the off switch
              @_setState(false)
              resolve()
          )
        else
          @_setState(state)
          @_base.info "Turning off not implemented"
          resolve()

    getState: () ->
      return Promise.resolve @_state

    destroy: () ->
      @_base.cancelUpdate()
      @xbox.disconnect()
      super()

  # ###Finally
  # Create a instance of my plugin
  xboxPlugin = new XboxPlugin
  # and return it to the framework.
  return xboxPlugin