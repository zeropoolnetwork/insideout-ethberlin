import Fastify from 'fastify';
import { program } from 'commander';

const state = {
  nodes: new Map<string, string>(),
};

program
  .option('-p, --port <port>', 'Port to listen on', '3000');

program.parse();
const options = program.opts();

const fastify = Fastify({
  logger: true
});

fastify.post('/nodes/register', async function handler(request, reply) {
  // @ts-ignore - TODO: Define body type
  const url = request.body.url;
  const id = Math.random().toString(36).substring(7);

  state.nodes.set(id, url);

  const pingInterval = setInterval(async () => {
    fastify.log.debug(`Pinging node ${id}`);

    // @ts-ignore - TODO: fix fetch type
    const res = await fetch(`${url}/ping`);
    const resJson = await res.json();

    if (res.status !== 200 || resJson !== 'pong') {
      fastify.log.error(`Node ${id} is down`, res);
      state.nodes.delete(id);
      clearInterval(pingInterval);
    }
  }, 1000 * 10);

  return { id };
});

async function main() {
  try {
    await fastify.listen({ port: options.port });
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
}

main();



