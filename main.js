var http = require("http");
var server = http.createServer(function(req,res) {
res.write("Hello World!!");
res.end();
});

// socket.ioの準備
var io = require('socket.io')(server);
clients = {};

// クライアント接続時の処理
io.on('connection', function(socket) {
	console.log("client connected!!")
	clients[socket.id] = socket;

	// クライアント切断時の処理
	socket.on('disconnect', function() {
		delete clients[socket.id]
	});
	// クライアントからの受信を受ける (socket.on)
	socket.on("from_client", function(obj){
		var keys = Object.keys(clients);
		if (keys.length > 1) {
			keys.some(function(v, i){
				if (v == socket.id) {
					keys.splice(i,1);    
				}
			});
		}
		var key = keys[Math.floor(keys.length * Math.random())]
		clients[key].emit("from_server", {id: key});
	});
});

server.listen(61130);
