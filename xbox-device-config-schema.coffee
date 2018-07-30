# #my-plugin configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "Xbox config options"
  type: "object"
  XboxPowerSwitch:
    title: "Xbox power switch"
    type: "object"
    properties:
      option1:
        description: "Just click save"
        type: "string"
        default: ""
}