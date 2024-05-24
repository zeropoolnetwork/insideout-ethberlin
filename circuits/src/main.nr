use dep::{std, std::{hash, merkle}};

type Hash = Field;
type IdenKey = Hash;

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
        hash::pedersen_hash([self.owner, self.balance])
    }
}

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

struct MerkleRoot {
    hash: Hash
}

impl Eq for MerkleRoot {
    fn eq(self, other: Self) -> bool {
        self.hash == other.hash
    }
}

impl MerkleRoot {
    fn new(n: u64) -> MerkleRoot {
        let mut v : Hash = 0;
        for _ in 0..n {
            // v = H(v, v)
            v = merkle::compute_merkle_root(v, 0, [v]);
        }
        MerkleRoot { hash: v }
    }

    fn update<N>(&mut self, index: Field, proof: [Hash; N], old_leaf: Hash, new_leaf: Hash) {
        assert_eq((*self).hash, merkle::compute_merkle_root(old_leaf, index, proof));
        (*self).hash = merkle::compute_merkle_root(new_leaf, index, proof);
    }
}

struct RollupState {
    accounts: MerkleRoot,
    storage: MerkleRoot,
    operator: (),
}

impl RollupState {
    fn init() -> RollupState {
        RollupState {
            accounts: MerkleRoot::new(0),
            storage: MerkleRoot::new(0),
            operator: (),
        }
    }

    fn hash(self) -> Hash {
        hash::pedersen_hash([self.accounts.hash, self.storage.hash])
    }
}

fn main(x: Field, y: pub Field) {
    assert(x != y);
}

#[test]
fn test_main() {
    main(1, 2);
    // Uncomment to make test fail
    // main(1, 1);
}
