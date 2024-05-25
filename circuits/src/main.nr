mod account;
mod file;
mod common;
// mod tx;
// mod mining;

use crate::common::poseidon2;
// use crate::tx::Tx;
// use crate::mining::MiningReq;

struct RollupState {
    accounts: Field,
    storage: Field,
}

impl RollupState {
    fn init() -> RollupState {
        RollupState {
            accounts: 0,
            storage: 0,
        }
    }

    fn hash(self) -> Field {
        poseidon2([self.accounts, self.storage])
    }
}

global OutN = 16;
global Depth = 20;
global BatchSize = 16;

fn main(
    old: pub Field,
    new: pub Field,
    time_now: pub Field,
    old_state: RollupState//,
    // mining_reqs: [MiningReq; BatchSize],
    // tx_reqs: [Tx<Depth,OutN>; BatchSize],
) {
    assert(1 != 2);
}

// #[test]
// fn test_main() {
//     main(1, 2);
//     // Uncomment to make test fail
//     // main(1, 1);
// }
