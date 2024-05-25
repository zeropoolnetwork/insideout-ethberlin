mod common;
mod rollup;
// mod tx;
// mod mining;

use crate::common::mt::poseidon2;
use crate::common::pub_encoding;
// use crate::tx::Tx;
// use crate::mining::MiningReq;

struct RollupState {
    /// Root hash of the Merkle tree storing accounts
    acc_root: Field,
    /// Root hash of the Merkle tree storing file info
    data_root: Field,
}

impl Eq for RollupState {
    fn eq(self, other: Self) -> bool {
        (self.acc_root == other.acc_root) & (self.data_root == other.data_root)
    }
}

impl RollupState {
    fn init(d: u64) -> RollupState {
        RollupState {
            acc_root: d as Field,
            data_root: d as Field,
        }
    }

    fn hash(self) -> Field {
        poseidon2([
            self.acc_root,
            self.data_root,
        ])
    }
}

global OutN = 1 << 4;
global StateDepth = 20;
global FileDepth = 10;
global BatchSize = 1 << 4;

fn main(
    public_params_hash: pub [u8; pub_encoding::BYTES_IN_KECCAK256],
    before: RollupState,
    after: RollupState,
    tx_block: rollup::tx::TxBlock<BatchSize, StateDepth>,
    file_block: rollup::file::TxBlock<BatchSize, StateDepth>,
    mining_block: rollup::mining::TxBlock<BatchSize, StateDepth, FileDepth>,
) {
    // Contract's public view is matched
    assert_eq(
        public_params_hash,
        pub_encoding::keccak256field([
            // These two hashes are the public view of the contract
            before.hash(),
            after.hash(),
        ])
    );

    let acc_root = before.acc_root;
    let data_root = before.data_root;


    assert_eq(
        after,
        RollupState {
            acc_root: acc_root,
            data_root: data_root,
        }
    );
}

// #[test]
// fn test_main() {
//     let a: Field = 1000000;
//     let bits = a.to_le_bits(10);
//     for i in 0..bits.len() {
//         let b = bits[i];
//         println(f"{b}");
//     }
//     // Uncomment to make test fail
//     // main(1, 1);
// }
