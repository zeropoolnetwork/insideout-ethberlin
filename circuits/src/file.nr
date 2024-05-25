use dep::std::hash;
use crate::common::{IdenKey, MerkleRoot,Hash};

struct File {
    /// Until when was it paid for
    expiryTime: Field,
    /// Who owns it (and has the right to delete/modify)
    owner: IdenKey,
    /// Merkle Root of the data
    data: MerkleRoot,
}

impl File {
    fn hash(self) -> Hash {
        hash::pedersen_hash([self.expiryTime, self.owner, self.data.hash])
    }
}
