http = require('http')

main = {
  speed: 4.0
  width: 616 + 45
  fps: 60
}

class DummyClient
  constructor: (index) ->
    @isDummy = true
    @index = index
  emit: (event, data) ->
    if event == 'somen'
      setTimeout =>
        main.server.handleSomen @, data
      , main.width / (main.speed * main.fps) * 1000


class Server
  constructor: ->
    @output = null
    @input = null
    @monitor = null
    @somenCounter = 0
    @clients = (new DummyClient(i) for i in [0...4])

    @server = http.createServer (req, res) ->
      res.write 'Hello World!!'
      res.end()
    @setupSocket()
    @server.listen 61130

  setupSocket: ->
    # socket.ioの準備
    io = require('socket.io')(@server)

    # クライアント接続時の処理
    io.on 'connection', (socket) =>
      console.log 'client connected!!'

      socket.emit 'greeting', { message: 'greeting' }, (data) =>
        if data.type == 'output'
          console.log 'found output!'
          @output = socket

        if data.type == 'input'
          console.log 'found input!'
          @input = socket

        if data.type == 'monitor'
          console.log 'found monitor!'
          @monitor = socket

        if data.type == 'normal'
          console.log 'found normal client'
          if data.index?
            index = data.index
          else
            index = 0
          socket.index = 0
          @clients[index] = socket
          console.log "clients: #{@clients.length}"

      # @clients[socket.id] = socket

      # クライアント切断時の処理
      socket.on 'disconnect', =>
        console.log 'client disconnected'
        # @clients = @clients.filter (x) -> x.id != socket.id
        if socket.index?
          index = socket.index
        else
          index = 0
        @clients[index] = new DummyClient(index)
        console.log "clients: #{@clients.length}"

      # クライアントからの受信を受ける (socket.on)
      socket.on 'somen', (data) =>
        @handleSomen socket, data

      socket.on 'somen/add', (data) =>
        @handleSomenAdd socket, data
      socket.on 'somen/remove', (data) =>
        @handleSomenRemove socket, data
      socket.on 'hashi/add', (data) =>
        @handleHashiAdd socket, data

  handleSomen: (socket, data) ->
    if not data.index?
      if socket == @input
        data.index = -1
        @somenCounter += 1
      else
        data.index = socket.index

    data.index += 1

    console.log "somen index: #{data.index}, id: #{data.id}"

    if data.index < @clients.length
      @clients[data.index].emit 'somen', data
      if @monitor?
        @monitor.emit 'somen', data
    else if @output?
      @output.emit 'somen', data
      @somenCounter -= 1

  handleSomenAdd: (socket, data) ->
    @somenCounter += 1
    if @monitor?
      @monitor.emit 'somen/add', data

  handleSomenRemove: (socket, data) ->
    if @monitor?
      @monitor.emit 'somen/remove', data
  handleHashiAdd: (socket, data) ->
    if @monitor?
      @monitor.emit 'hashi/add', data


main.server = new Server()
