use dep::std::hash;
use crate::common::{IdenKey, MerkleRoot, Hash, poseidon2};

struct File {
    /// Until when was it paid for
    expiryTime: Field,
    /// Who owns it (and has the right to delete/modify).
    /// `owner == 0` means that the file was erased
    owner: IdenKey,
    /// Merkle Root of the data
    data: MerkleRoot,
}

impl File {
    fn hash(self) -> Hash {
        poseidon2([self.expiryTime, self.owner, self.data.hash])
    }

    fn is_valid(self) -> bool {
        self.owner != 0
    }

    fn invalidate(&mut self) {
        (*self).owner = 0;
    }
}
