Handler = require './handler'

querystring = require 'querystring'

class HttpHandler extends Handler
  protocol: 'http'
  httpServer: undefined

  parseBody: (httpRequest, httpResponse) =>
    data = ''
    httpRequest.on 'data', (chunk) => data += chunk
    httpRequest.on 'end', () =>
      httpRequest.rawBody = data
      # TODO Should we end this if Content-Type is not set even if no data are being sent?
      if data
        try
        # BUG content-type might hold more than one types
        # TODO Move these to utilities or some more generic place
          switch httpRequest.headers['content-type']
            when 'application/x-www-form-urlencoded'
              httpRequest.body = querystring.parse data
            when 'application/json'
              httpRequest.body = JSON.parse data
            else
            # BUG Remove until it can accept 'application/json; charset=utf-8' etc.
            # httpRequest.body = data
              httpResponse.writeHead 415
              httpResponse.end 'Unsupported Media Type'

              return
        catch errParsing
          httpResponse.writeHead 500
          httpResponse.end 'Could not decode JSON from body.'

          return

      @normalize httpRequest, httpResponse

  # Receives the http.ClientRequest and http.ClientResponse for the vhost.
  # Constructs the request and response obejcts required by our Router.
  # Dispatches them to the Router.
  normalize: (httpRequest, httpResponse, cb) =>
    headers = httpRequest.headers

    ctx =
      transport: 'http'
      http:
        req: httpRequest
        res: httpResponse
      req:
        hostname: httpRequest.hostname
        method: httpRequest.method.toLowerCase()
        headers: httpRequest.headers or []
        body: httpRequest.body
        query: httpRequest.query or []
        path: httpRequest.url or ''

      send: (body) ->
        body = JSON.stringify body if typeof body isnt "string"
        httpResponse.end body

    @dispatch ctx

  constructor: (@bi) ->
    @bi.server.on 'request', (httpRequest, httpResponse) =>
      httpResponse.setHeader 'Access-Control-Allow-Origin', '*'
      httpResponse.setHeader 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
      httpResponse.setHeader 'Access-Control-Allow-Headers', 'Content-Type, X-Token'
      return httpResponse.end undefined if httpRequest.method is 'OPTIONS'

      @normalize httpRequest, httpResponse

exports = module.exports = HttpHandler