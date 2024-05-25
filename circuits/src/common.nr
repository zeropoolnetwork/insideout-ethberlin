use dep::std::hash::poseidon2::Poseidon2;


/// Path and proof start with indices that are close to the leaf
pub fn merkle_root_from_path<N>(leaf: Field, index_bits: [u1; N], hash_path: [Field; N]) -> Field {
    let n = hash_path.len();
    let mut current = leaf;
    for i in 0..n {
        let path_bit = index_bits[i] as bool;
        let (hash_left, hash_right) = if path_bit {
            (hash_path[i], current)
        } else {
            (current, hash_path[i])
        };
        current = poseidon2([hash_left, hash_right]);
    }
    current
}




/// Helper around Noir's clunky API
pub fn poseidon2<N>(input: [Field; N]) -> Field {
    Poseidon2::hash(input, input.len())
}

