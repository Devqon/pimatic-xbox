# #my-plugin configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "pimatic-xbox device config schemas"
  XboxPowerSwitch:
    title: "Xbox power switch"
    type: "object"
    properties:
      option1:
        description: "Just click save"
        type: "string"
        default: ""
}