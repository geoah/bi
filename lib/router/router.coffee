EventEmitter = require('events').EventEmitter
Route = require './route'

url = require 'url'

# Allows to find a relevant (if any) Route for a given Request.

class Router extends EventEmitter
  routes: undefined
  vhostRegexp: /^(.*)$/i

  testVhost: (hostname) ->
    @vhostRegexp.test hostname

  # Tries to find a valid Route for the given request.
  # Returns the Route or false if no Routes match the request.
  resolve: (ctx) ->
    # logger.debug "[Router] Testing #{@vhostRegexp} against #{request.hostname}"
    if @testVhost ctx.hostname
      for route in @routes
        if ctx.method?
          if ctx.method in route.methods
            urlParts = url.parse ctx.path, true
            pathname = urlParts.pathname
            params = route.match pathname
            if params isnt false
              paramsObj = {}
              paramsObj[key] = value for key, value of params
              ctx.params = paramsObj
              ctx.query = urlParts.query
              return route
    return false

  dispatch: (ctx) =>
    route = @resolve ctx
    # logger.debug "[router] Checking '#{request.method} #{request.path}'..."
    if route
      # logger.info "[router] '#{request.method} #{request.path}' " +
      #   "Route matched... (#{route.method} #{route.path})"
      # We assume that if there is a listener it will handle the request.
      # if @emit 'route-found', route, request, response
      # else
      console.info 'Router', 'info', "Matched with route '#{route.methods} #{route.path}'"
      route.dispatch ctx
      return true
    else
      return false

  use: (stack...) ->
    @stack = @stack.concat stack
    return @

  route: (methods, path, stack...) ->
    methods = [methods] if typeof methods is 'string'
    for method in methods
      method = method.toLowerCase()
    path = "/#{path}" if path[0] isnt '/'
    console.info "Adding #{methods} #{path}."
    route = new Route @, methods, path, stack...
    @routes.push route

  constructor: (routes, vhostRegexp) ->
    @routes = if routes then routes else []
    @vhostRegexp = vhostRegexp if vhostRegexp
    @stack = []

exports = module.exports = Router