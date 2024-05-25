use crate::common::poseidon2;

struct File {
    /// Until when was it paid for
    expiryTime: Field,
    /// Who owns it (and has the right to delete/modify).
    /// `owner == 0` means that the file was erased
    owner: Field,
    /// Merkle Root of the data
    data_root: Field,
}

impl File {
    fn hash(self) -> Field {
        poseidon2([self.expiryTime, self.owner, self.data_root])
    }

    fn is_valid(self) -> bool {
        self.owner != 0
    }

    fn invalidate(&mut self) {
        (*self).owner = 0;
    }
}
