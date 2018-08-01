# #my-plugin configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "Xbox config options"
  type: "object"
  XboxPowerSwitch:
    title: "Xbox power switch"
    type: "object"
    properties:
      host:
        description: "The host or IP address of the xbox"
        type: "string"
        default: ""
      liveId:
        description: "Xbox live Id"
        type: "string",
        default: ""
      tries:
        description: "Number of tries to send power packets"
        type: "number"
        default: 5
      delay:
        description: "Delay between power packets"
        type: "number"
        default: 1000
      type:
        description: "The type of xbox"
        type: "string"
        enum: ["xbox-one"]
        default: "xbox-one"
}