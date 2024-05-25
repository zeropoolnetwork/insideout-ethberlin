import random
from eth_hash.auto import keccak

MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617
RANDOM_ORACLE_SIZE = 16
HASH_PAYLOAD_SIZE = 4 + RANDOM_ORACLE_SIZE
HASH_U8_PAYLOAD_SIZE = 32 * HASH_PAYLOAD_SIZE

class RandomOracle:
    def __init__(self):
        self.offset = random.randint(0, MODULUS - 1)
        self.data = [random.randint(0, MODULUS - 1) for _ in range(RANDOM_ORACLE_SIZE)]

class RollupPubInput:
    def __init__(self):
        self.old_root = random.randint(0, MODULUS - 1)
        self.new_root = random.randint(0, MODULUS - 1)
        self.now = random.randint(0, MODULUS - 1)
        self.oracle = RandomOracle()

def serialize_rollup_input(rollup_input):
    payload = [0] * HASH_PAYLOAD_SIZE
    payload[0] = rollup_input.old_root
    payload[1] = rollup_input.new_root
    payload[2] = rollup_input.now
    payload[3] = rollup_input.oracle.offset
    for i in range(RANDOM_ORACLE_SIZE):
        payload[4 + i] = rollup_input.oracle.data[i]
    return payload

def hash_payload(payload):
    bytes_payload = bytearray(HASH_U8_PAYLOAD_SIZE)
    for i in range(HASH_PAYLOAD_SIZE):
        bytes_payload[i*32:(i+1)*32] = payload[i].to_bytes(32, 'big')
    
    hash_result = keccak(bytes_payload)
    
    return int.from_bytes(hash_result, 'big') % MODULUS


rollup_input = RollupPubInput()


payload = serialize_rollup_input(rollup_input)
hash_value = hash_payload(payload)


noir_code = f"""

#[test]
fn test_rollup_input_hash() {{
    let rollup_input = RollupPubInput {{
        old_root: {rollup_input.old_root},
        new_root: {rollup_input.new_root},
        now: {rollup_input.now},
        oracle: RandomOracle {{
            offset: {rollup_input.oracle.offset},
            data: {rollup_input.oracle.data}
        }}
    }};

    let pubhash = {hash_value};
    
    assert_eq(
        pubhash,
        rollup_input.hash()
    );
}}
"""

print(noir_code)

