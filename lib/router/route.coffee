parsePath = (require "../utils").parsePath

class Route
  # Attempts to run through all middleware functions.
  # If any middleware calls next(err) the route will return a 500 error.
  dispatch: (bi) => # TODO , out) =>
    index = 0
    stack = @router.stack.concat @stack

    returnValues = []

    next = (err, returnValue) ->
      layer = stack[index++]

      # TODO No middleware sent any response
      # if not layer and ...
      #   response.send 404, '...'

      if err
        console.error "#{err}"
        return bi.send err, 500

      if returnValue
        returnValues.push returnValue

      # Move to the next layer
      layer bi, next

    next()

  # Tries to match given path to Route's path.
  # If the path provided matches the Route's RegExp it returns the matched params.
  # Else it returns false.
  match: (path) =>
    params = []
    matches = @regexp.exec path
    console.info @regexp, path
    unless matches then return false
    for i, match of matches[1..]
      key = if @keys[i] then @keys[i].name else false
      match = if typeof match is 'string' then decodeURIComponent match else match
      if key then params[key] = match else params.push match
    params

  constructor: (router, methods, path, stack...) ->
    @router = router
    @keys = []
    @methods = methods
    @options = undefined
    @path = path
    # Create a RegExp from the provided path and save it for @match()
    @regexp = parsePath @path, @keys #, @options.sensitive, @options.strict
    @stack = stack

exports = module.exports = Route