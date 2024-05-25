mod account;
mod file;
mod common;

use dep::std::hash::pedersen_hash;
// dep::std::hash::poseidon2::Poseidon2
use crate::common::{MerkleRoot, Hash};

struct RollupState {
    accounts: MerkleRoot,
    storage: MerkleRoot,
    operator: (),
}

impl RollupState {
    fn init() -> RollupState {
        RollupState {
            accounts: MerkleRoot::new(0),
            storage: MerkleRoot::new(0),
            operator: (),
        }
    }

    fn hash(self) -> Hash {
        pedersen_hash([self.accounts.hash, self.storage.hash])
    }
}

fn main(x: Field, y: pub Field) {
    assert(x != y);
}

#[test]
fn test_main() {
    main(1, 2);
    // Uncomment to make test fail
    // main(1, 1);
}
