mod common;
mod rollup;


use rollup::{tx, file, mining};
use rollup::root::Root;


global RANDOM_ORACLE_SIZE:u32=16;
global HASH_PAYLOAD_SIZE:u32=4+RANDOM_ORACLE_SIZE;
global HASH_U8_PAYLOAD_SIZE:u32=32*HASH_PAYLOAD_SIZE;


global ACCOUNT_AND_DATA_TREE_DEPTH:u32=10;
global FILE_TREE_DEPTH:u32=10;

global MAX_TX_PER_BLOCK:u32=8;
global MAX_FILE_PER_BLOCK:u32=8;
global MAX_MINING_PER_BLOCK:u32=1;


struct RollupPubInput {
    old_root: Field,
    new_root: Field,
    now: Field,
    oracle: mining::RandomOracle<RANDOM_ORACLE_SIZE>
}

struct RollupInput {
    public: RollupPubInput,
    old_root: Root,
    new_root: Root,
    tx: tx::Block<MAX_TX_PER_BLOCK, ACCOUNT_AND_DATA_TREE_DEPTH>,
    file: file::Block<MAX_FILE_PER_BLOCK, ACCOUNT_AND_DATA_TREE_DEPTH>,
    mining: mining::Block<MAX_MINING_PER_BLOCK, ACCOUNT_AND_DATA_TREE_DEPTH, FILE_TREE_DEPTH>
}

impl RollupPubInput {
    fn hash(self) -> Field {


        let mut payload = [0; HASH_PAYLOAD_SIZE];
        payload[0] = self.old_root;
        payload[1] = self.new_root;
        payload[2] = self.now;
        payload[3] = self.oracle.offset;
        for i in 0..RANDOM_ORACLE_SIZE {
            payload[4+i] = self.oracle.data[i];
        }
        
        let mut bytes_payload = [0; HASH_U8_PAYLOAD_SIZE];

        for i in 0..HASH_PAYLOAD_SIZE {
            // use BE for Ethereum compatibility
            let bytes = payload[i].to_be_bytes(32);
            for j in 0..32 {
                bytes_payload[i*32+j] = bytes[j];
            }
        }

        let res = dep::std::hash::keccak256(bytes_payload, HASH_U8_PAYLOAD_SIZE);

        let mut acc = 0;

        // use BE for Ethereum compatibility
        for i in 0..32 {
            acc = acc*256 + res[i] as Field;
        }
        acc
    }
}


#[export]
fn main(
    pubhash: pub Field,
    input: RollupInput
) {
    // check the public input hash
    assert_eq(
        pubhash,
        input.public.hash()
    );

    // check roots

    assert_eq(
        input.public.old_root,
        input.old_root.hash()
    );

    assert_eq(
        input.public.new_root,
        input.new_root.hash()
    );


    // apply blocks
    let acc_root = input.old_root.acc;
    let data_root = input.old_root.data;


    let acc_root = input.tx.apply(acc_root);

    let (acc_root, data_root) = input.file.apply(acc_root, data_root, input.public.now);

    let acc_root = input.mining.apply(acc_root, data_root, input.public.oracle);

    // check the new roots
    assert_eq(
        input.new_root.acc,
        acc_root
    );

    assert_eq(
        input.new_root.data,
        data_root
    );
}

#[test]
fn test_rollup_input_hash() {
    let rollup_input = RollupPubInput {
        old_root: 8918192209170995053702057230737241803337815611010203629775354209885370389637,
        new_root: 16883437091946480525328209831531237890634231029399717242983301882663446976393,
        now: 2089219850256167021614320445642961704853440022375543021380913753290554232094,
        oracle: mining::RandomOracle {
            offset: 19564933442608081724400236810305259559367395926194797124512609460106891757291,
            data: [2867903460422775183770252526445680822902260914741587409824326547207677449059, 8982059045193534856455115822855918079595979808050890144324375955477946872189, 8244606625356446328877588669345450740862722818968998233427305821443894298209, 2563331886220690115962865958996205782709996400410509944924024279779346858039, 4259287321668842861877945919250867372941655907983388880560121334145963464931, 13248443777284381212066333999324606216389209264761780664247552934952189807540, 20285832049167006555500366542975364483258018426785093480667760483324743362771, 5917574112058539259682488696363169814842830831565158865983549040317943619437, 5481112740512213277275567931578112635682204031814479186103196781426700777820, 2279985499514197233096628895612771540916719469378559248315569321638892674880, 17352348601282685282647606324939267344833087544148193972442404046889178826693, 4134703512352786192752684457112133135552477746155015642132205955914068294964, 20437528133140263981883173304601792611852858774503433718207914253936981139074, 14405569952615555161430534061004859201629453046842863205908548834064772152782, 7479156532127664218920775497597575535701336444222197405485291397698853279057, 11457425749485331896983930651284471892797617913351140334030139034158893475386]
        }
    };

    let pubhash = 3948662352623793037980422332430756023521811098554192536177723934080377254970;
    
    assert_eq(
        pubhash,
        rollup_input.hash()
    );
}
