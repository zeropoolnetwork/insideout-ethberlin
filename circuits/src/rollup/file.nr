use crate::common::mt::{MerkleProof, poseidon2};
use crate::common::ec::SignaturePacked;
use crate::common::from_le_bits;

use crate::rollup::tx::Account;

// hardcode price for storing
global PRICE: Field = 1;

struct File {
    /// Until when was it paid for
    expiration_time: Field,
    /// Who owns it (and has the right to delete/modify).
    /// `owner == 0` means that the file was erased
    owner: Field,
    /// Merkle Root of the data
    data: Field,
}


impl File {
    pub fn is_writeable(self, now:Field, sender:Field) -> bool {
        let expired = self.expiration_time.lt(now);
        let empty = self.owner == 0;
        let owned = self.owner == sender;

        expired | empty | owned
    }

    pub fn hash(self) -> Field {
        poseidon2([self.expiration_time, self.owner, self.data])
    }
}

struct Tx {
    sender_index: Field,
    data_index: Field,
    time_interval: Field,
    data: Field,
    nonce: Field
}

struct TxAssets<N> {
    proof_sender: MerkleProof<N>,
    proof_file: MerkleProof<N>,
    account_sender: Account,
    file: File,
    signature: SignaturePacked,
}

struct TxEx<N> {
    tx: Tx,
    assets: TxAssets<N>
}

impl Tx {
    pub fn hash(self) -> Field {
        poseidon2([self.sender_index, self.data_index, self.time_interval, self.data, self.nonce])
    }
}

impl<N> TxEx<N> {
    pub fn apply(self, acc_root:Field, data_root:Field, now:Field) -> (Field, Field) {
        let TxEx{tx, assets} = self;
        let is_blank = assets.signature.a == 0;
        
        // check signature
        let txhash = tx.hash();
        assert(is_blank | (assets.signature.verify(txhash)));

        let fee = PRICE * tx.time_interval;

        // check overflow
        assert(is_blank | (!assets.account_sender.balance.lt(fee)));

        // sender should be correct
        assert(is_blank | (assets.account_sender.key == assets.signature.a));

        // check merkle path for sender
        assert(is_blank | (tx.sender_index == from_le_bits(assets.proof_sender.index_bits)));

        // check nonce
        assert(is_blank | (assets.account_sender.nonce == tx.nonce));

        // deinitialize sender if balance is zero
        let new_account_sender = {
            let balance = assets.account_sender.balance - fee;
            let (key, nonce, random_oracle_nonce) = if balance == 0 {
                (0,0,0)
            } else {
                (assets.account_sender.key, tx.nonce + 1, assets.account_sender.random_oracle_nonce)
            };

            Account {key, balance, nonce, random_oracle_nonce}
        };

        // update sender
        let new_acc_root = assets.proof_sender.update(assets.account_sender.hash(), new_account_sender.hash(), acc_root);

        // check access to the file
        assert(is_blank | (assets.file.is_writeable(now, assets.account_sender.key)));

        // check merkle path for file
        assert(is_blank | (tx.data_index == from_le_bits(assets.proof_file.index_bits)));

        // update file
        let new_file = {
            let expiration_time = (if assets.file.expiration_time.lt(now) {
                now
            } else {
                assets.file.expiration_time 
            }) + tx.time_interval;

            let data =  if tx.data == 0 {
                assets.file.data
            } else {
                tx.data
            };

            File {
                expiration_time,
                owner: assets.account_sender.key,
                data
            }
        };

        let new_data_root = assets.proof_file.update(assets.file.hash(), new_file.hash(), data_root);
        if is_blank {
            (acc_root, data_root)
        } else {   
            (new_acc_root, new_data_root)
        }
    }
}

struct Block<M,N> {
    txs: [TxEx<N>; M]
}

impl<M,N> Block<M,N> {
    fn apply(self, acc_root:Field, data_root:Field, now:Field) -> (Field, Field) {
        let mut cur_acc = acc_root;
        let mut cur_data = data_root;

        for i in 0..M {
            let (acc, data) = self.txs[i].apply(cur_acc, cur_data, now);
            cur_acc = acc;
            cur_data = data;
        }
        
        (cur_acc, cur_data)
    }
}
