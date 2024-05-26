import { Fr } from '@aztec/bb.js';
import { SparseMerkleTree } from './sparse-merkle-tree';
import seedrandom from 'seedrandom';

const ACCOUNT_AND_DATA_TREE_DEPTH = 10;
const FILE_TREE_DEPTH = 10;

type MiningResult = {
  mining_nonce: number,
  bruteforce_hash: Fr,
  index_hash: Fr,
  index: number,
  data: Fr,
  mining_hash: Fr,
};

function trim(f: Fr, n: number): Fr {
  const fBigInt: bigint = BigInt(f.toString());
  let res = 0n;
  let cur = 1n;

  for (let i = 0; i < n; i++) {
    const bit = fBigInt & cur;
    res = res | bit;
  }

  return Fr.fromString(res.toString());
}

// FIXME: we use one one sameple, production will use more
//
//
export async function mine(
  tree: SparseMerkleTree,
  pk: Fr,
  oracle: Fr,
): Promise<MiningResult | null> {
  const bb = tree.bb;
  const MAX_MINING_NONCE = 1048576;
  const DIFFICULTY = 28269553036454149273332760011886696253239742350009903329945699220681916416n;

  for (let mining_nonce = 0; mining_nonce < MAX_MINING_NONCE; mining_nonce++) {
    const bruteforce_hash =
      await bb.poseidon2Hash([pk, oracle, Fr.fromString(mining_nonce.toString())]);
    const index_hash = 
      await bb.poseidon2Hash([bruteforce_hash]);
    const index : number = Number(trim(index_hash, ACCOUNT_AND_DATA_TREE_DEPTH + FILE_TREE_DEPTH).toString());
    const data = await tree.getLeaf(index);
    const mining_hash =
      await bb.poseidon2Hash([bruteforce_hash, data]);

    if (BigInt(mining_hash.toString()) < DIFFICULTY)
      return {
        mining_nonce: mining_nonce,
        bruteforce_hash: bruteforce_hash,
        index_hash: index_hash,
        index: index,
        data: data,
        mining_hash: mining_hash,
      }
  }

  return null;
}
