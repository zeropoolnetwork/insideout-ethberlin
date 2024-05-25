mod common;
mod rollup;

use rollup::mining::RandomOracle;


global RANDOM_ORACLE_SIZE:u32=16;
global HASH_PAYLOAD_SIZE:u32=4+RANDOM_ORACLE_SIZE;
global HASH_U8_PAYLOAD_SIZE:u32=32*HASH_PAYLOAD_SIZE;

struct RollupInput {
    old_root: Field,
    new_root: Field,
    clock: Field,
    oracle: RandomOracle<RANDOM_ORACLE_SIZE>
}

impl RollupInput {
    fn hash(self) -> Field {


        let mut payload = [0; HASH_PAYLOAD_SIZE];
        payload[0] = self.old_root;
        payload[1] = self.new_root;
        payload[2] = self.clock;
        payload[3] = self.oracle.offset;
        for i in 0..RANDOM_ORACLE_SIZE {
            payload[4+i] = self.oracle.data[i];
        }
        
        let mut bytes_payload = [0; HASH_U8_PAYLOAD_SIZE];

        for i in 0..HASH_PAYLOAD_SIZE {
            // use BE for Ethereum compatibility
            let bytes = payload[i].to_be_bytes(32);
            for j in 0..32 {
                bytes_payload[i*32+j] = bytes[j];
            }
        }

        let res = dep::std::hash::keccak256(bytes_payload, HASH_U8_PAYLOAD_SIZE);

        let mut acc = 0;
        for i in 0..32 {
            acc = acc*256 + res[i] as Field;
        }

        acc
    }
}


fn main(
    pubhash: pub Field,
    input: RollupInput
) {
    assert_eq(
        pubhash,
        input.hash()
    );
}

