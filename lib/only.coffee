only =
  ws: (ctx, next) -> if ctx.transport in ["ws", "wss"] then next() else next "Invalid protocol"
  http: (ctx, next) -> if ctx.transport in ["http", "https"] then next() else next "Invalid protocol"

exports = module.exports = only