http = require('http')

server = http.createServer (req, res) ->
  res.write 'Hello World!!'
  res.end()

# socket.ioの準備
io = require('socket.io')(server)
clients = []

output = null
input = null
somenCounter = 0

# クライアント接続時の処理
io.on 'connection', (socket) ->
  console.log 'client connected!!'

  socket.emit 'greeting', { message: 'greeting' }, (data) ->
    if data.type == 'output'
      console.log 'found output!'
      output = socket

    if data.type == 'input'
      console.log 'found input!'
      input = socket

    if data.type == 'normal'
      console.log 'found normal client'
      clients.push socket
      console.log "clients: #{clients.length}"


  # clients[socket.id] = socket

  # クライアント切断時の処理
  socket.on 'disconnect', ->
    console.log 'client disconnected'
    clients = clients.filter (x) -> x.id != socket.id
    console.log "clients: #{clients.length}"

  # クライアントからの受信を受ける (socket.on)
  socket.on 'somen', (data) ->
    if not data.index?
      data.index = clients.indexOf(socket)
      data.id = somenCounter
      somenCounter += 1
    console.log "somen index: #{data.index}, id: #{data.id}"

    if socket != input
      data.index += 1

    if data.index < clients.length
      clients[data.index].emit 'somen', data
    else if output?
      output.emit 'somen', data


server.listen 61130
