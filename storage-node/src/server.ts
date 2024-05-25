import { program } from 'commander';
import io from 'socket.io-client';
import { SparseMerkleTree, MapNodeStorage } from './sparse-merkle-tree';
import { MerkleTree } from './merkle-tree';
import { Fr } from '@aztec/bb.js';
import { FileMetadata, FileStorage } from './file-storage';
import express, { Express, Request, Response } from 'express';
import cors from 'cors';


// async function test() {
//   const leaves = [];
//   for (let i = 0; i < 2 ** 10; i++) {
//     leaves.push(Fr.random());
//   }

//   console.log('Start');
//   const start = Date.now();
//   const tree = await MerkleTree.new(leaves);
//   const end = Date.now();
//   console.log('End:', end - start, 'ms');

//   console.log('Root:', tree.getRoot().toString());
// }

// test();

const storage = new FileStorage(2 ** 12);

program
  .option('-p, --port <port>', 'Port to listen on', '3001')
  .option('-m, --master <address>', 'Master node (coordinator) URL');

program.parse();
const options = program.opts();

console.log('Connecting to master node:', options.master || process.env.MASTER);
const socket = io(options.master || process.env.MASTER, { autoConnect: true });

socket.on('connect', () => {
  console.log('Connected to master node');
});

socket.on('disconnect', () => {
  console.log('Disconnected from master node');
});

socket.on('error', (err) => {
  console.error('Socket error:', err);
});

// socket.on('reqFile', async (fileId: string, callback: (data: Buffer | undefined) => void) => {
//   console.log('Requested file:', fileId);

//   const data = await storage.read(fileId);

//   callback(data);
// });

socket.on('uploadFile', async (data: Buffer, name: string, metadata: FileMetadata) => {
  console.log('Saving file:', name, metadata);
  try {
    await storage.reserve(name, metadata);
    await storage.write(name, data);
  } catch (err) {
    console.error('Error uploading file:', err);
    return;
  }
});

const app: Express = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.raw({ type: '*/*' }));
app.use(cors())

app.get('/files/:id', async (req: Request, res: Response) => {
  const data = await storage.read(req.params.id);

  if (!data) {
    res.status(404).send('File not found');
    return;
  }

  // FIXME: only supports JPEG for now
  res.setHeader('Content-Type', 'image/jpeg');

  res.send(data);
});

app.get('/status', async (req: Request, res: Response) => {
  res.send({ status: 'OK' });
});

app.listen(process.env.PORT || options.port, () => {
  console.log('Listening on port', options.port);
});
