import { Fr } from '@aztec/bb.js';
import { MerkleTree } from './merkle-tree';
import seedrandom from 'seedrandom';

// FIXME: WIP
export async function mine(tree: MerkleTree, oracle: Fr, numSamples: number, nonce: number, difficulty: bigint): Promise<bigint> {
  const bb = tree.bb;

  let hash = 0n;
  do {
    const samples: Fr[] = await sampleLeaves(tree, numSamples, nonce);
    const h = await bb.poseidon2Hash([...samples, oracle]);
    hash = BigInt(h.toString());
  } while (hash > difficulty);

  return hash;
}

async function sampleLeaves(tree: MerkleTree, numSamples: number, seed: number): Promise<Fr[]> {
  const rng = seedrandom(seed);
  const samples = [];
  const numLeaves = tree.capacity();
  const indicesTaken = [];

  for (let i = 0; i < numSamples; i++) {
    let index = Math.floor(rng() * numLeaves);
    samples.push(await tree.getLeaf(index));
    indicesTaken.push(index);
  }

  return samples;
}
