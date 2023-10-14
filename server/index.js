const UDP = require('dgram')
const server = UDP.createSocket('udp4')
const port = 2223
var clients = [];
var agent,game,count_agent,count_game;
var attempts = 5000
var broadcastInterval = 0

function reset(v)
{
  if (v=='game' || v=="reset")
  {
    game = { 
      player: { x: 0, y: 0, distance: 0, velocity: 0, score: 0, seconds: 0, wall: 0, walls: [0,0,0,0], dangers: [0,0,0,0], direction: [0,0,0,0], colision: false, atual_action: -1 }, 
      enemy: { x: 0, y: 0, distance: 0 },  
      coins: [{x:0,y:0,has:false,distance:0,colision:false, direction: [0,0,0,0] }], 
      info: {gamestate: 0},
      socket: 'game' 
    }
    count_game = attempts;
  }
  if (v=='agent' || v=="reset")
  {
    agent = { action: -1, restart: false, socket: 'agent' }
    count_agent = attempts;
  }
}

function broadcast()
{
  var playing = { agent, game }
  //console.log(playing);
  for (var client in clients) {
    if (client) {
      client = JSON.parse(client);
      var port = client[1];
      var address = client[0];
      server.send(JSON.stringify(playing), port, address, (err) => {});
    }
  }
  if (count_agent==0) { reset("agent"); }
  if (count_game==0) { reset("game"); }
  count_agent--;
  count_game--;
}

server.on('listening', () => {
  // Server address it’s using to listen
  var address = server.address();
  reset('reset');
  console.log('Listining to ', 'Address: ', address.address, 'Port: ', address.port);
  setInterval(broadcast, broadcastInterval);
})

server.on('message', (m, i) => {

  try {
    res = JSON.parse(m);
    if (res.socket == "game") {
      count_game=attempts;
      game = res;
    } else if (res.socket == "agent") {
      count_agent=attempts;
      agent = res;
    }
  } catch (err) {
    //console.log(err);
  }

  clients[JSON.stringify([i.address, i.port])] = true;
  //broadcast();
})

server.on('error', (err) => {
  console.error(`server error:\n${err.stack}`);
  server.close();
});

server.bind(port)
