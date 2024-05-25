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
    accounts_i: u32,
    storage: MerkleRoot,
    storage_i: u32,
}

impl RollupState {
    fn init(d: u64) -> RollupState {
        RollupState {
            accounts: MerkleRoot::new(d),
            accounts_i: 1,
            storage: MerkleRoot::new(d),
            storage_i: 1,
        }
    }

    fn hash(self) -> Hash {
        poseidon2([
            self.accounts.hash,
            self.accounts_i as Field,
            self.storage.hash,
            self.storage_i as Field,
        ])
    }
}

global OutN = 1 << 4;
global Depth = 20;
global BatchSize = 1 << 4;

fn main(
    old: pub Hash,
    new: pub Hash,
    /// Time. Used to expire files that run out of money
    time_now: pub u64,
    /// Contract's balance change (due to external deposits, withdrawals)
    delta: pub u64,
    /// Seed from Random Oracle, used for mining
    r: pub Field,
    /// State before transaction
    old_state: RollupState,
    /// Mining requests, processed on old_state
    mining_reqs: [MiningReq; BatchSize],
    /// Transactions moving balances and creating files
    tx_reqs: [Tx<Depth,OutN>; BatchSize],
) {
    // The plan for `main` is:
    // 
    // 1. Validate the mining requests,
    // 2. Deposit tokens for miners,
    // 3. Perform transactions,
    // 4. Assert that the resulting state hashes to `new`

    assert(1 != 2);
}

// #[test]
// fn test_main() {
//     main(1, 2);
//     // Uncomment to make test fail
//     // main(1, 1);
// }
