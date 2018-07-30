module.exports = (env) ->

  Promise = env.require 'bluebird'
  xbox = env.require 'xbox-on'

  class XboxPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      env.logger.info("Hello World")

      deviceConfigDef = require("./xbox-device-config-schema")

      @framework.deviceManager.registerDeviceClass("XboxPowerSwitch", {
        configDef: deviceConfigDef.XboxPowerSwitch,
        createCallback: (config) => new XboxPowerSwitch(config)
      })


  class XboxPowerSwitch extends env.devices.PowerSwitch
    constructor: (@config) ->
      @_base = commons.base @, @config.class
      @name = @config.name
      @id = @config.id
      if @config.type is "xbox-one"
        @xbox = new Xbox(@config.ip, @config.liveId)
      else
        @xbox = null
        @_base.error "Only xbox-one is supported for now"
      super()

    changeStateTo: (state) ->
      self = this
      return new Promise((resolve, reject) -> 
        if state
          @_base.debug "Trying to power the xbox"
          options = {
            tries: 5,
            delay: 1000,
            waitForCallback: true
          }
          @xbox.powerOn(options, err =>
            if err
              @_base.rejectWithErrorString reject, if err instanceof Error then err else "Could not turn on xbox"
            else
              @_base.debug "Xbox powered on"
              self._setState(state)
              resolve()
          )
        else
          self._setState(state)
          @_base.info "Turning off not implemented"
      )

    getState: () ->
      return Promise.resolve @_state

  # ###Finally
  # Create a instance of my plugin
  xboxPlugin = new XboxPlugin
  # and return it to the framework.
  return xboxPlugin