class Handler
  protocol: undefined
  routers: undefined

  dispatch: (ctx) =>
    #for routerName, router of @bi.routers
    router = @bi.router
    # Test available routers and forward request
    return router.dispatch ctx if router.resolve ctx
    ctx.send 'Could not find route', 404

  normalize: (request, response) =>
    throw 'Missing normalize method.'

  constructor: (@bi) ->
    throw 'Missing constructor.'

exports = module.exports = Handler