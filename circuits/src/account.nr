use dep::std::hash;
use crate::common::{IdenKey, Hash, bool2field};

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
        hash::pedersen_hash([self.owner, self.balance, bool2field(self.spent)])
    }
}
