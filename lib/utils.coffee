# Creates a RegExp based on a given path. This RegExp will be matched against paths provided by connect.
# Shamelessly ripped off ExpressJs v3

module.exports.parsePath = (path, keys, sensitive, strict) ->
  return path if toString.call(path) is '[object RegExp]'
  path = '(' + path.join('|') + ')'  if Array.isArray(path)
  path = path.concat(if strict then '' else '/?').replace(/\/\(/g, '(?:/').replace(/(\/)?(\.)?:(\w+)(?:(\(.*?\)))?(\?)?(\*)?/g, (_, slash, format, key, capture, optional, star) ->
    keys.push name: key, optional: !!optional
    slash = slash or ''
    '' + (if optional then '' else slash) + '(?:' + (if optional then slash else '') + (format or '') + (capture or (format and '([^/.]+?)' or '([^/]+?)')) + ')' + (optional or '') + (if star then '(/*)?' else '')
  ).replace(/([\/.])/g, "\\$1").replace(/\*/g, '(.*)')
  new RegExp('^' + path + '$', (if sensitive then '' else 'i'))