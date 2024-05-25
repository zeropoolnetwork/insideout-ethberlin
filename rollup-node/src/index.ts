
import { program } from 'commander';
import express, { Express, Request, Response } from 'express';
import http from 'node:http';
import { Server as SocketIOServer } from 'socket.io';

program
  .option('-p, --port <port>', 'Port to listen on', '3000');

program.parse();
const options = program.opts();

const app: Express = express();
const server = new http.Server(app);
const io = new SocketIOServer(server);

io.on('connection', (socket) => {
  console.log('New node connected');

  socket.on('disconnect', () => {
    console.log('Node disconnected');
  });

  socket.on('error', (err) => {
    console.error('Socket error:', err);
  });
});

app.get('/files/:id', async (req: Request, res: Response) => {
  const data: Buffer = await new Promise((resolve, reject) => {
    io.emit('reqFile', req.params.id, (data: Buffer) => {
      resolve(data);
    });
  });

  res.send(data);
});

server.listen(options.port, function () {
  console.log(`listening on ${options.port}`);
});
