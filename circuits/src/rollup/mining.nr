use crate::rollup::tx::Account;
use crate::rollup::file::File;

use crate::common::mt::{MerkleProof, poseidon2};
use crate::common::ec::SignaturePacked;
use crate::common::{from_le_bits, trim};


global REV_DIFFICULTY: Field = 28269553036454149273332760011886696253239742350009903329945699220681916416; //1 << (254 - 10)
global MAX_MINING_NONCE = 1048576; //1<<20
global MINING_REWARD: Field = 1024; //1<<10


struct RandomOracle<N> {
    offset: Field,
    data: [Field; N]
}

impl<N> RandomOracle<N> {
    // get random_nonce of given data or -1 if not valid
    fn get_nonce(self, data:Field) -> Field {
        
        let mut res = -1;
        for i in 0..N {
            if self.data[i] == data {
                res = self.offset + i as Field;
            }
        }
        res
    }
}


struct Tx {
    sender_index: Field,
    nonce: Field,
    random_oracle_nonce: Field,
    mining_nonce: Field
}

struct TxAssets<N,K> {
    proof_sender: MerkleProof<N>,
    account_sender: Account,
    random_oracle_value: Field,
    // for simplicity we will make just one single lookup for data state
    // should be changed in production
    proof_file: MerkleProof<N>,
    file: File,
    proof_data_in_file: MerkleProof<K>,
    data_in_file: Field,
    signature: SignaturePacked

}

struct TxEx<N,K> {
    tx: Tx,
    assets: TxAssets<N,K>
}

impl Tx {
    fn hash(self) -> Field {
        poseidon2([self.sender_index, self.nonce, self.random_oracle_nonce, self.mining_nonce])
    }
}

impl<N,K> TxEx<N,K> {
    pub fn apply<O>(self, acc_root:Field, data_root:Field, random_oracle:RandomOracle<O>) -> Field {
        let TxEx{tx, assets} = self;
        let is_blank = assets.signature.a == 0;

        // check signature
        let txhash = tx.hash();
        assert(is_blank | (assets.signature.verify(txhash)));

        // check overflow
        assert(is_blank | (!(assets.account_sender.balance + MINING_REWARD).lt(assets.account_sender.balance)));

        // sender should be correct
        assert(is_blank | (assets.account_sender.key == assets.signature.a));

        // check merkle path for sender
        assert(is_blank | (tx.sender_index == from_le_bits(assets.proof_sender.index_bits)));

        // check nonce
        assert(is_blank | (assets.account_sender.nonce == tx.nonce));

        // check oracle value
        assert(is_blank | (random_oracle.get_nonce(assets.random_oracle_value) == tx.random_oracle_nonce));

        // check oracle nonce
        assert(is_blank | (assets.account_sender.random_oracle_nonce.lt(tx.random_oracle_nonce)));

        // check merkle proof for file
        assert(is_blank | (assets.proof_file.root(assets.file.hash()) == data_root));
        
        // check merkle proof for data in file
        assert(is_blank | (assets.proof_data_in_file.root(assets.data_in_file) == assets.file.data));
        
        ///// MINING BEGIN /////
        {
            let index = from_le_bits(assets.proof_data_in_file.index_bits) + ((1<<K) as Field) * from_le_bits(assets.proof_file.index_bits);
            let bruteforce_hash = poseidon2([assets.signature.a, assets.random_oracle_value, tx.mining_nonce]);
            let index_hash = poseidon2([bruteforce_hash]);

            assert(is_blank | (index == trim(index_hash, N+K as u32)));

            let mining_hash = poseidon2([bruteforce_hash, assets.data_in_file]);
            assert(is_blank | (mining_hash.lt(REV_DIFFICULTY)));
        }
        ///// MINING END /////

        // update account
        let new_account_sender = Account {
            key: assets.account_sender.key,
            balance: assets.account_sender.balance + MINING_REWARD,
            nonce: tx.nonce + 1,
            random_oracle_nonce: tx.random_oracle_nonce
        };

        let new_acc_root = assets.proof_sender.update(acc_root, assets.account_sender.hash(), new_account_sender.hash());

        if is_blank {
            new_acc_root
        } else {
            acc_root
        }
    }
}

struct Block<M,N,K> {
    txs: [TxEx<N,K>; M]
}

impl<M,N,K> Block<M,N,K> {
    fn apply<O>(self, acc_root:Field, data_root:Field, random_oracle:RandomOracle<O>) -> Field {
        let mut cur = acc_root;
        for i in 0..M {
            cur = self.txs[i].apply(cur, data_root, random_oracle);
        }
        cur
    }
}