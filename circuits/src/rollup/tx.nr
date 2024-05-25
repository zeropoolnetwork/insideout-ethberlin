use crate::common::mt::MerkleProof;
use crate::common::ec::SignaturePacked;

struct Tx {
    sender_index: Field,
    receiver_index: Field,
    receiver_key: Field,
    amount: Field 
}

struct TxAssets<N> {
    proof_sender: MerkleProof<N>,
    proof_receiver: MerkleProof<N>,
    signature: SignaturePacked,

}
