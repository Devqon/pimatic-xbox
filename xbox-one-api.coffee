module.exports = (env) ->

  Promise = env.require 'bluebird'
  commons = require('pimatic-plugin-commons')(env)
  xbox = require 'xbox-on'

  class XboxOneApi
    constructor: (@config) =>
      @_base = commons.base @, "XboxOneApi"
      @liveId = @config.liveId
      @host = @config.host
      @xbox = null

    powerOn: () =>
      return _turnOn()

    powerOff: () =>
      return new Promise (resolve, reject) =>
        @_base.error "Powering off an xbox one is not supported"
        resolve()

    destroy: () =>
      @xbox = null

    _ensureXbox: () =>
      if @xbox is null
        @xbox = new xbox(@host, @liveId)

    _turnOn: () =>
      @_ensureXbox()
      return new Promise (resolve, reject) =>
        options = {
          tries: 5,
          delay: 1000,
          waitForCallback: false
        }
        @xbox.powerOn(options, (err) =>
          if err
            @_base.rejectWithErrorString reject, if err instanceof Error then err else "Could not turn on xbox"
          else
            @_base.debug "Xbox powered on"
            resolve()
      )
      