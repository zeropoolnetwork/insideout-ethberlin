use crate::common::mt::{MerkleProof, poseidon2};
use crate::common::ec::SignaturePacked;
use crate::common::from_le_bits;

struct Account {
    /// x coordinate of the owner account public key
    key: Field,
    /// Balance
    balance: Field,
    // Nonce
    nonce: Field,
    // Mining nonce
    random_oracle_nonce: Field
}

impl Account {
    fn hash(self) -> Field {
        poseidon2([self.key, self.balance, self.nonce, self.random_oracle_nonce])
    }
}


struct Tx {
    sender_index: Field,
    receiver_index: Field,
    receiver_key: Field,
    amount: Field,
    nonce: Field
}

struct TxAssets<N> {
    proof_sender: MerkleProof<N>,
    proof_receiver: MerkleProof<N>,
    account_sender: Account,
    account_receiver: Account,
    signature: SignaturePacked,
}

struct TxEx<N> {
    tx: Tx,
    assets: TxAssets<N>
}

impl Tx {
    fn hash(self) -> Field {
        poseidon2([self.sender_index, self.receiver_index, self.receiver_key, self.amount, self.nonce])
    }
}


impl<N> TxEx<N> {
    pub fn apply(self, root: Field) -> Field {
        let TxEx {tx, assets} = self;
        let is_blank = assets.signature.a == 0;

        // check signatures
        let txhash = tx.hash();
        assert(is_blank | (assets.signature.verify(txhash)));

        // check overflows
        assert(is_blank | (!assets.account_sender.balance.lt(tx.amount)));
        assert(is_blank | (!(assets.account_receiver.balance + tx.amount).lt(assets.account_receiver.balance)));

        // receiver should be correct or zero. Then we will initialize it with account_receiver
        assert(is_blank | ((assets.account_receiver.key == tx.receiver_key) | (assets.account_receiver.key == 0)));

        // sender should be correct
        assert(is_blank | (assets.account_sender.key == assets.signature.a));

        // check merkle paths
        assert(is_blank | (tx.sender_index == from_le_bits(assets.proof_sender.index_bits)));
        assert(is_blank | (tx.receiver_index == from_le_bits(assets.proof_receiver.index_bits)));
        
        // prohibit self-sending
        assert(is_blank | (tx.sender_index != tx.receiver_index));

        // check nonce
        assert(is_blank | (assets.account_sender.nonce == tx.nonce));

        // deinitialize sender if balance is zero
        let new_account_sender = {
            let balance = assets.account_sender.balance - tx.amount;
            let (key, nonce, random_oracle_nonce) = if balance == 0 {
                (0,0,0)
            } else {
                (assets.account_sender.key, tx.nonce + 1,assets.account_sender.random_oracle_nonce)
            };

            Account {key, balance, nonce, random_oracle_nonce}
        };

        let new_account_receiver = Account {
            key: tx.receiver_key, 
            balance: assets.account_receiver.balance + tx.amount,
            nonce: assets.account_receiver.nonce,
            random_oracle_nonce: assets.account_receiver.random_oracle_nonce
        };

        let mut cur = root;

        // update sender
        cur = assets.proof_sender.update(assets.account_sender.hash(), new_account_sender.hash(), cur);

        // update receiver
        cur = assets.proof_receiver.update(assets.account_receiver.hash(), new_account_receiver.hash(), cur);

        if is_blank {
            root
        } else {
            cur
        }
    }
}

struct Block<M,N> {
    txs: [TxEx<N>; M]
}

impl<M,N> Block<M,N> {
    fn apply(self, root:Field) -> Field {
        let mut cur = root;
        for i in 0..M {
            cur = self.txs[i].apply(cur);
        }
        cur
    }
}