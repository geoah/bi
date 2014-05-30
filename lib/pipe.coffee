#class ExtendedBi extends Bi
#  constructor: (uri) ->
#    @on 'message', (bi, cb) ->
#      console.info 'message', bi.data
#      cb 'Got it, thanks.'
#
#    super uri

#endpointA = bi.endpoint('ws://endpoint-a.local:3000')
#endpointB = bi.endpoint('ws://endpoint-b.local:3000')

#endpointA.emit 'message', foo: 'bar', (bi) ->
#  console.info 'message response', bi.data