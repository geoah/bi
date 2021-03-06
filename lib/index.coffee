http = require 'http'

Router = require './router/router'
Route = require './router/route'
HttpHandler = require './handler/httpHandler'
WsHandler = require './handler/wsHandler'

class Bi
  constructor: (server) ->
    @server = server
    @router = new Router

    @handlers =
      http: new HttpHandler @
      ws: new WsHandler @

  api: (basePath, endpoints) ->
    for endpoint, stack of endpoints
      stack = [stack] if typeof stack is 'function'
      switch endpoint
        when "all" then @route ["get", "all"], "#{basePath}", stack...
        when "one" then @route ["get", "all"], "#{basePath}/:id", stack...
        when "insert" then @route ["post", "insert"], "#{basePath}", stack...
        when "update" then @route ["put", "update"], "#{basePath}/:id", stack...
        when "remove" then @route ["delete", "remove"], "#{basePath}/:id", stack...
        else @route endpoint, "#{basePath}", stack...

  route: (methods, path, stack...) ->
    @router.route methods, path, stack...

  use: (stack...) ->
    @router.use stack...

exports = module.exports = Bi