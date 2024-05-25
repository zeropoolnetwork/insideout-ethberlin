type Hash = Field;
type IdenKey = Hash;

struct MerkleRoot {
    hash: Hash
}

impl Eq for MerkleRoot {
    fn eq(self, other: Self) -> bool {
        self.hash == other.hash
    }
}

/// Path and proof start with indices that are close to the leaf
fn merkle_root_from_path<N>(leaf: Hash, path: [u1; N], proof: [Hash; N]) -> Hash {
    let mut acc = leaf;
    for i in 0 .. proof.len() {
        acc = if path[i] == 1 {
            poseidon2([acc, proof[i]])
        } else {
            poseidon2([acc, proof[i]])
        };
    }
    acc
}

impl MerkleRoot {
    fn new(n: u64) -> MerkleRoot {
        let mut v : Hash = 0;
        for _ in 0..n {
            v = poseidon2([v, v]);
        }
        MerkleRoot { hash: v }
    }

    /// Assert that the leaf has given hash
    fn assert_leaf<N>(self, leaf: Hash, path: [u1; N], proof: [Hash; N]) {
        assert_eq(self.hash, merkle_root_from_path(leaf, path, proof));
    }

    /// Replace old leaf by the new one
    fn set<N>(&mut self, old_leaf: Hash, new_leaf: Hash, path: [u1; N], proof: [Hash; N]) {
        (*self).assert_leaf(old_leaf, path, proof);
        (*self).hash = merkle_root_from_path(new_leaf, path, proof);
    }
}

/// Helper around Noir's clunky API
pub fn poseidon2<N>(input: [Field; N]) -> Field {
    dep::std::hash::poseidon2::Poseidon2::hash(input, input.len())
}
