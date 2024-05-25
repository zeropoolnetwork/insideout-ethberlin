use dep::std::hash::poseidon2::{Poseidon2, Poseidon2Hasher};


struct MerkleProof<N> {
    index_bits: [u1; N],
    hash_path: [Field; N],
}


impl<N> MerkleProof<N> {
    pub fn root(self, leaf: Field) -> Field {
        merkle_root_from_path(leaf, self)
    }

    pub fn update(self, leaf: Field, new_leaf: Field, old_root: Field) -> Field {
        assert(self.root(leaf) == old_root);
        self.root(new_leaf)
    }
    
}

/// Path and proof start with indices that are close to the leaf
pub fn merkle_root_from_path<N>(leaf: Field, proof:MerkleProof<N>) -> Field {
    let n = proof.hash_path.len();
    let mut current = leaf;
    for i in 0..n {
        let path_bit = proof.index_bits[i] as bool;
        let next = proof.hash_path[i];
        let (hash_left, hash_right) = if path_bit {
            (next, current)
        } else {
            (current, next)
        };
        current = poseidon2([hash_left, hash_right]);
    }
    current
}




/// Helper around Noir's clunky API
pub fn poseidon2<N>(input: [Field; N]) -> Field {
    Poseidon2::hash(input, input.len())
}


// use dep::std::hash::poseidon2::Poseidon2Hasher;

// let mut hasher = Poseidon2Hasher::default();
// eddsa_verify_with_hasher(pub_key_a.x, pub_key_a.y, s_a, r8_a.x, r8_a.y, msg, &mut hasher);