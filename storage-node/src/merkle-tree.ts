import { Fr, Barretenberg } from '@aztec/bb.js';
import { cpus } from 'os';

export class MerkleTree {
  height: number = 0;
  tree: Fr[] = [];
  bb: Barretenberg = {} as Barretenberg;

  static async new(leaves: Fr[]): Promise<MerkleTree> {
    const self = new MerkleTree();

    self.bb = await Barretenberg.new({ threads: cpus().length });
    self.height = Math.ceil(Math.log2(leaves.length)) + 1;
    self.tree = new Array((1 << self.height) - 1);

    await self.buildTree(leaves);

    return self;
  }

  async hash(left: Fr, right: Fr = left) {
    return await this.bb.poseidon2Hash([left, right]);
  }

  async buildTree(leaves: Fr[]) {
    let offset = 0;
    for (let i = 0; i < leaves.length; i++) {
      this.tree[offset + i] = leaves[i];
    }

    let levelSize = leaves.length;
    offset += leaves.length;

    while (levelSize > 1) {
      let nextLevelSize = Math.ceil(levelSize / 2);
      for (let i = 0; i < nextLevelSize; i++) {
        const left = this.tree[offset - levelSize + i * 2];
        const right = this.tree[offset - levelSize + i * 2 + 1];
        this.tree[offset + i] = await this.hash(left, right);
      }
      levelSize = nextLevelSize;
      offset += levelSize;

      console.log('Level:', levelSize);
    }
  }

  getRoot() {
    return this.tree[this.tree.length - 1];
  }

  getProof(index: number) {
    let proof = [];
    let offset = 0;
    let levelSize = 2 ** this.height;

    while (levelSize > 1) {
      let isRightNode = index % 2 === 1;
      let pairIndex = isRightNode ? index - 1 : index + 1;

      if (pairIndex < levelSize) {
        proof.push(this.tree[offset + pairIndex]);
      }

      index = Math.floor(index / 2);
      offset += levelSize;
      levelSize = Math.ceil(levelSize / 2);
    }

    return proof;
  }

  getLeaf(index: number): Fr {
    if (index >= 2 ** this.height) {
      throw new Error('Invalid index');
    }

    return this.tree[this.tree.length];
  }
}
