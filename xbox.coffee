module.exports = (env) ->

  Promise = env.require 'bluebird'
  commons = require('pimatic-plugin-commons')(env)
  xbox = require 'xbox-on'

  class XboxPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./xbox-device-config-schema")

      @framework.deviceManager.registerDeviceClass("XboxPowerSwitch", {
        configDef: deviceConfigDef.XboxPowerSwitch,
        createCallback: (config) => new XboxPowerSwitch(config, @config)
      })


  class XboxPowerSwitch extends env.devices.PowerSwitch
    constructor: (@config, @pluginConfig) ->
      @_base = commons.base @, @config.class
      @name = @config.name
      @id = @config.id
      if @pluginConfig.type is "xbox-one"
        @_base.debug "Initializing xbox with ip #{@pluginConfig.ip} and live id #{@pluginConfig.liveId}"
        @xbox = new xbox(@pluginConfig.ip, @pluginConfig.liveId)
      else
        @xbox = null
        @_base.error "Only xbox-one is supported for now"
      @_state = false
      super()

    changeStateTo: (state) ->
      return new Promise (resolve, reject) => 
        if state
          @_base.info "Trying to power the xbox #{@xbox.id} #{@xbox.ip}"
          options = {
            tries: 5,
            delay: 1000,
            waitForCallback: true
          }
          @xbox.sendOn((err) =>
            @_base.info "callback from xbox #{err || 'err'}"
            if err
              @_base.rejectWithErrorString reject, if err instanceof Error then err else "Could not turn on xbox"
            else
              @_base.info "Xbox powered on"
              @_setState(state)
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
      super()

  # ###Finally
  # Create a instance of my plugin
  xboxPlugin = new XboxPlugin
  # and return it to the framework.
  return xboxPlugin