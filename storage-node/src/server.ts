import Fastify from 'fastify';
import { program } from 'commander';

program
  .option('-p, --port <port>', 'Port to listen on', '3000')
  .option('-m, --master <address>', 'Master node (coordinator) URL')
  .option('-u, --url <url>', 'Node URL');

program.parse();
const options = program.opts();

const fastify = Fastify({
  logger: true
});

fastify.get('/ping', async function handler(request, reply) {
  return 'pong';
});

fastify.post('/upload', async function handler(request, reply) {
  // 1. Check the signature
  // 2. Chech the reserved slots for the user
  // 3. Write the file to the reserved slot
});

fastify.post('/reserve', async function handler(request, reply) {
  return { hello: 'world' };
});

fastify.get('/download/:id', async function handler(request, reply) {
  return { hello: 'world' };
});

async function main() {
  // @ts-ignore - TODO: fix fetch type
  const res = await fetch(`${options.master}/nodes/register`, {
    method: 'POST',
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      url: options.url,
    }),
  });
  const resJson = await res.json() as { id: string };

  console.log(`Registered with master node. Assigned node ID: ${resJson.id}`);

  try {
    await fastify.listen({ port: options.port });
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
}

main();



