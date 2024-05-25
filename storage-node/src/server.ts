import { program } from 'commander';
import io from 'socket.io-client';

program
  .option('-p, --port <port>', 'Port to listen on', '3000')
  .option('-m, --master <address>', 'Master node (coordinator) URL');

program.parse();
const options = program.opts();

console.log('Connecting to master node:', options.master);
const socket = io(options.master, { autoConnect: true });

socket.on('connect', () => {
  console.log('Connected!');
});
socket.emit('CH01', 'me', 'test msg');




