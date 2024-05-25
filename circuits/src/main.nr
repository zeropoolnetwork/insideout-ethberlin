mod file;
mod common;
mod rollup;
// mod tx;
// mod mining;

use crate::common::mt::poseidon2;
use crate::common::pub_encoding;
// use crate::tx::Tx;
// use crate::mining::MiningReq;

struct RollupState {
    accounts: Field,
    accounts_i: u32,
    storage: Field,
    storage_i: u32,
}

impl RollupState {
    fn init(d: u64) -> RollupState {
        RollupState {
            accounts: d as Field,
            accounts_i: 1,
            storage: d as Field,
            storage_i: 1,
        }
    }

    fn hash(self) -> Field {
        poseidon2([
            self.accounts,
            self.accounts_i as Field,
            self.storage,
            self.storage_i as Field,
        ])
    }
}

global OutN = 1 << 4;
global Depth = 20;
global BatchSize = 1 << 4;

fn main(
    public_params_hash: pub [u8; pub_encoding::BYTES_IN_KECCAK256],
    old: Field,
    new: Field,
    /// Time. Used to expire files that run out of money
    time_now: Field,
    /// Contract's balance change (due to external deposits, withdrawals)
    delta: Field,
    /// Seed from Random Oracle, used for mining
    r: Field,
    /// State before transaction
    old_state: RollupState//,
    // /// Mining requests, processed on old_state
    // mining_reqs: [MiningReq; BatchSize],
    // /// Transactions moving balances and creating files
    // tx_reqs: [Tx<Depth,OutN>; BatchSize],
) {
    assert_eq(
        public_params_hash,
        pub_encoding::keccak256field([
            old,
            new,
            time_now,
            delta,
            r
        ])
    );

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
