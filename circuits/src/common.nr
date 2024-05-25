mod mt;
mod ec;


pub fn from_le_bits<N>(bits: [u1;N]) -> Field {
    let mut res = 0;
    let mut cur = 1;
    for i in 0..N {
        res += cur * bits[i] as Field;
        cur *= 2;
    }
    res
}

pub fn trim(f:Field, n:u32) -> Field {
    let f_bits = f.to_le_bits(n);
    let mut res = 0;
    let mut cur = 1;
    for i in 0..n {
        res += cur * f_bits[i] as Field;
        cur *= 2;
    }
    res
}