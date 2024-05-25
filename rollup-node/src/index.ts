
import { program } from 'commander';
import express, { Express, Request, Response } from 'express';
import http from 'node:http';
import { Server as SocketIOServer } from 'socket.io';
import { Level } from 'level';
import { Fr } from '@aztec/bb.js';
import cors from 'cors';
import { id } from 'ethers';

program
  .option('-p, --port <port>', 'Port to listen on', '3000');

program.parse();
const options = program.opts();

const app: Express = express();
const server = new http.Server(app);
const io = new SocketIOServer(server);

const EXPIRATION: number = 1000 * 60 * 60 * 24 * 7; // 1 week
const RESERVATION_COST: number = 1;

interface AccountState {
  balance: number;
  files: string[];
}

// FIXME: mock
const state = {
  accounts: new Level<string, AccountState>('accounts', { valueEncoding: 'json' }),
};

io.on('connection', (socket) => {
  console.log('New node connected');

  socket.on('disconnect', () => {
    console.log('Node disconnected');
  });

  socket.on('error', (err) => {
    console.error('Socket error:', err);
  });
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.raw({ type: '*/*' }));
app.use(cors())

// app.get('/files/:id', async (req: Request, res: Response) => {
//   const data: Buffer = await new Promise((resolve, reject) => {
//     io.emit('reqFile', req.params.id, (data: Buffer) => {
//       resolve(data);
//     });
//   });

//   res.send(data);
// });

interface FileMetadata {
  ownerId: string;
  // expirationDate: Date;
  size: number;
}

// FIXME: mock
// TODO: Split into two endpoints: reserve and upload?
app.post('/files', async (req: Request, res: Response) => {
  console.log('Uploading file:', req.body.metadata);
  const metadata: FileMetadata = req.body.metadata;
  const expirationDate = new Date(Date.now() + EXPIRATION);
  let account: AccountState;
  try {
    account = await state.accounts.get(metadata.ownerId as string); // FIXME: check signature
  } catch (err) {
    res.status(400).send({ error: 'Account not found' });
    return;
  }

  if (account.balance < RESERVATION_COST) {
    res.status(400).send({ error: 'Insufficient balance' });
    return;
  }

  const fileName = Fr.random().toString(); // FIXME: use hash
  const data = Buffer.from(req.body.data, 'base64');

  io.emit('uploadFile', data, fileName, { ...metadata, expirationDate });

  account.files.push(fileName);
  account.balance -= RESERVATION_COST;
  await state.accounts.put(metadata.ownerId as string, account);

  res.send({ fileName });
});

// FIXME: mock
app.post('/accounts/:id/mint', async (req: Request, res: Response) => {
  const accountId = req.params.id as string;
  let account: AccountState;

  try {
    account = await state.accounts.get(accountId);
    account.balance += req.body.amount;
    await state.accounts.put(accountId, account);
  } catch (err) {
    await state.accounts.put(accountId, { balance: req.body.amount, files: [] });
    account = await state.accounts.get(accountId)!;
  }

  res.send(account);
});

// FIXME: mock
app.get('/accounts/:id', async (req: Request, res: Response) => {
  const accountId = req.params.id as string;

  let account: AccountState;
  try {
    account = await state.accounts.get(accountId);
  } catch (err) {
    account = { balance: 0, files: [] };
  }

  res.send(account);
});

app.get('/status', async (req: Request, res: Response) => {
  res.send({ status: 'OK' });
});

server.listen(process.env.PORT || options.port, function () {
  console.log(`Listening on ${options.port}`);
});
