mod account;
mod file;
mod common;
mod tx;
mod mining;

use crate::common::{MerkleRoot, Hash, poseidon2};
use crate::tx::Tx;
use crate::mining::MiningReq;

struct RollupState {
    accounts: MerkleRoot,
    storage: MerkleRoot,
}

impl RollupState {
    fn init() -> RollupState {
        RollupState {
            accounts: MerkleRoot::new(0),
            storage: MerkleRoot::new(0),
        }
    }

    fn hash(self) -> Hash {
        poseidon2([self.accounts.hash, self.storage.hash])
    }
}

global OutN = 16;
global Depth = 20;
global BatchSize = 16;

fn main(
    old: pub Hash,
    new: pub Hash,
    time_now: pub Field,
    old_state: RollupState,
    mining_reqs: [MiningReq; BatchSize],
    tx_reqs: [Tx<Depth,OutN>; BatchSize],
) {
    assert(1 != 2);
}

// #[test]
// fn test_main() {
//     main(1, 2);
//     // Uncomment to make test fail
//     // main(1, 1);
// }
