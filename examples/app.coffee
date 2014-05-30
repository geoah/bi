Bi = require "./../lib/index"

http = require "http"
only = require "./../lib/only"

# Dummy Controller
users =
  find: (ctx, next) -> ctx.send "users"
  findOne: (ctx, next) -> ctx.send "user with id #{ctx.params.id}"
  upsert: (ctx, next) -> ctx.send "creating/editing user with name #{ctx.body.name}"
  remove: (ctx, next) -> ctx.send "removing user with id #{ctx.params.id}"
  subscribe: (ctx, next) -> ctx.send "subscribed to receive user notices"

# Create an Http Server
server = http.Server()

# New Bi instance
bi = new Bi server

# Blank Http & Ws Middleware
bi.use (bi, next) ->
  console.info 'dummy middleware for everything.'
  next()

# Resourceful Routing
bi.api 'users',
  all: users.find       # Http: GET /users, Ws: users:get
  one: users.findOne    # Http: GET /users/id, Ws: users/id:get
  insert: users.upsert  # Http: POST /users, Ws: users:insert
  update: users.upsert  # Http: PUT /users/id, Ws: users/id:update
  remove: users.remove  # Http: DELETE /users/id, Ws users/id:remove
  subscribe: only.ws, users.subscribe

# Simple Routing
bi.route 'get', 'token', only.http, (ctx) -> ctx.send 'you need to post something'
bi.route 'post', 'token', only.http, (ctx) -> ctx.send token: 'something'
bi.route 'get', 'do/:something/:with?/:optional?/:params?', only.http, (ctx) -> ctx.send ctx.params

server.listen 3000
