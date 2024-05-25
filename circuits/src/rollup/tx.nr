use crate::common::mt::{MerkleProof, poseidon2};
use crate::common::ec::SignaturePacked;
use crate::common::from_le_bits;

struct Account {
    /// x coordinate of the owner account public key
    key: Field,
    /// Balance
    balance: Field,
}

impl Account {
    fn hash(self) -> Field {
        poseidon2([self.key, self.balance])
    }
}


struct Tx {
    sender_index: Field,
    receiver_index: Field,
    receiver_key: Field,
    amount: Field 
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
        poseidon2([self.sender_index, self.receiver_index, self.receiver_key, self.amount])
    }
}


impl<N> TxEx<N> {
    pub fn apply(self, root: Field) -> Field {
        let TxEx {tx, assets} = self;

        // check signatures
        let txhash = tx.hash();
        assert(assets.signature.verify(txhash));

        // check overflows
        assert(!assets.account_sender.balance.lt(tx.amount));
        assert(!(assets.account_receiver.balance + tx.amount).lt(assets.account_receiver.balance));

        // receiver should be correct or zero. Then we will initialize it with account_receiver
        assert((assets.account_receiver.key == tx.receiver_key) | (assets.account_receiver.key == 0));

        // sender should be correct
        assert(assets.account_sender.key == assets.signature.a);

        // check merkle paths
        assert(tx.sender_index == from_le_bits(assets.proof_sender.index_bits));
        assert(tx.receiver_index == from_le_bits(assets.proof_receiver.index_bits));
        
        // prohibit self-sending
        assert(tx.sender_index != tx.receiver_index);

        // deinitialize sender if balance is zero
        let new_account_sender = {
            let balance = assets.account_sender.balance - tx.amount;
            let key = if balance == 0 {0} else {assets.account_sender.key};
            Account {key, balance}
        };

        let new_account_receiver = Account {key: tx.receiver_key, balance: assets.account_receiver.balance + tx.amount};

        let mut cur = root;

        // update sender
        cur = assets.proof_sender.update(assets.account_sender.hash(), new_account_sender.hash(), cur);

        // update receiver
        cur = assets.proof_receiver.update(assets.account_receiver.hash(), new_account_receiver.hash(), cur);

        cur
    }
}

struct TxBlock<M,N> {
    txs: [TxEx<N>; M]
}

impl<M,N> TxBlock<M,N> {
    fn apply(self, root:Field) -> Field {
        let mut cur = root;
        for i in 0..M {
            cur = self.txs[i].apply(cur);
        }
        cur
    }
}