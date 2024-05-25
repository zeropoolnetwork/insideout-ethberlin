use dep::std::eddsa::eddsa_verify_with_hasher;
use dep::std::hash::poseidon2::Poseidon2Hasher;

mod subgroup_decompress;

// struct EdDSASignature {
//     r: Field,
//     s: Field,
// }

// impl EdDSASignature {
//     pub fn new(r: Field, s: Field) -> Self {
//         EdDSASignature { r, s }
//     }

//     pub fn verify(&self, message: Field) -> bool {

//     }
// }


fn main(x: Field, y: pub Field) {
    assert(x != y);
}

#[test]
fn test_main() {
    main(1, 2);
}
