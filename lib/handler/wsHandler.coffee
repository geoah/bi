Handler = require './handler'

io = require('socket.io')()
middleware = require("socketio-wildcard")()

io.use middleware

class WsHandler extends Handler
  protocol: 'ws'
  webSocketServer: undefined

  normalize: (socket) =>
    headers = socket.handshake.headers

    socket.on "*", (packet) =>
      event = packet.data[0]
      body = packet.data[1]
      cb = packet.data[2] # BUG Does not exist if no cb is provided on the client

      [path, method] = event.split ':'

      ctx =
        transport: 'ws'
        ws: socket
        req:
          hostname: headers.host
          method: method or 'get'
          headers: headers
          body: body
          query: [] # TODO Parse event for query
          path: path

        send: (body) ->
          cb body if cb

      @dispatch ctx

  constructor: (@bi) ->
    # Create a Websocket Server and attach it on the http server.
    # TODO Check if routers accepts this host and if not terminate connection.
    @io = io.listen @bi.server

    # Forwards incoming messages.
    @io.on 'connection', (socket) =>
      @normalize socket

exports = module.exports = WsHandler