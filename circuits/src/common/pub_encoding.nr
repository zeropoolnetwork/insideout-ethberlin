use dep::std::hash;

global BYTES_IN_FIELD = 32;
global N_HASHED_PUBS = 2;
global BYTES_IN_KECCAK256 = 32;

/// Serialize given Field elements and compute Keccak hash of them
pub fn keccak256field(input: [Field; N_HASHED_PUBS]) -> [u8; BYTES_IN_KECCAK256] {
    let payload: [u8; BYTES_IN_FIELD * N_HASHED_PUBS] =
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