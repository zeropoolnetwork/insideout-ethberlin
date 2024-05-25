use dep::std::merkle;

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

impl MerkleRoot {
    fn new(n: u64) -> MerkleRoot {
        let mut v : Hash = 0;
        for _ in 0..n {
            // v = H(v, v)
            v = merkle::compute_merkle_root(v, 0, [v]);
        }
        MerkleRoot { hash: v }
    }

    fn update<N>(&mut self, index: Field, proof: [Hash; N], old_leaf: Hash, new_leaf: Hash) {
        assert_eq((*self).hash, merkle::compute_merkle_root(old_leaf, index, proof));
        (*self).hash = merkle::compute_merkle_root(new_leaf, index, proof);
    }
}

/// Helper around Noir's clunky API
pub fn poseidon2<N>(input: [Field; N]) -> Field {
    dep::std::hash::poseidon2::Poseidon2::hash(input, input.len())
}
