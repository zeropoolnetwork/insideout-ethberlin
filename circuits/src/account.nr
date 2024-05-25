use dep::std::hash;
use crate::common::{IdenKey, Hash, poseidon2};

struct Account {
    /// Signing PK hash
    owner: IdenKey,
    /// Balance
    balance: Field,
    /// Was it spent
    spent: bool,
}

impl Account {
    fn hash(self) -> Hash {
        poseidon2([self.owner, self.balance, self.spent as Field])
    }
}
