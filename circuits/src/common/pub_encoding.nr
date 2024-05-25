use dep::std::hash;

global BYTES_IN_FIELD = 8;
global HASHED_PUBS = 5;
global KECCAK256_WIDTH = 32;

/// Serialize given Field elements and compute Keccak hash of them
pub fn keccak256field(input: [Field; HASHED_PUBS]) -> [u8; KECCAK256_WIDTH] {
    let payload: [u8; BYTES_IN_FIELD * HASHED_PUBS] =
        input.fold(
            [].as_slice(),
            |acc: [u8], v: Field| {
                // Conversion to array and back is dumb, but that's what makes
                // Noir's loop checker happy
                let u : [u8; BYTES_IN_FIELD] = v.to_le_bytes(BYTES_IN_FIELD).as_array();
                acc.append(u.as_slice())
            }
        ).as_array();
    hash::keccak256(payload, payload.len() as u32)
}
