import { Fr } from "@aztec/bb.js";
import { MerkleTree } from "./merkle-tree";

// FIXME: WIP
export async function mine(tree: MerkleTree, oracle: Fr, numSamples: number, difficulty: bigint) {
  const bb = tree.bb;

  let hash = 0n;
  do {
    const samples: Fr[] = [];
    const h = await bb.poseidon2Hash([...samples, oracle]);
    hash = BigInt(h.toString());
  } while (hash > difficulty);
}
