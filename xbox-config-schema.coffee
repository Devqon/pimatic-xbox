# #my-plugin configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "Xbox config options"
  type: "object"
  properties:
    ip:
      description: "IP address of the xbox"
      type: "string"
      default: ""
    liveId:
      description: "Xbox live Id"
      type: "string",
      default: ""
    type:
      description: "The type of xbox"
      type: "string"
      enum: ["xbox-one"]
      default: "xbox-one"
}