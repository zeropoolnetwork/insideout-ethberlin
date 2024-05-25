use crate::common;
use crate::account::{Account};
use crate::file::{File};

struct Tx<Depth,OutN> {

    // Consume one account, create OutN new ones
    account_in: Account,
    account_in_i: [u1; Depth],
    accounts_out: [Account; OutN],

    // Consume one file, create OutN new ones
    file_in: File,
    file_in_i: [u1; Depth],
    files_out: [File; OutN],

}
