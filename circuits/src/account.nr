use crate::common::mt::poseidon2;

struct Account {
    /// x coordinate of the owner account public key
    owner: Field,
    /// Balance
    balance: Field,
}

impl Account {
    fn hash(self) -> Field {
        poseidon2([self.owner, self.balance])
    }
}
