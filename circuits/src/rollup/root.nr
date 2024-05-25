use crate::common::mt::poseidon2;


struct Root {
    acc: Field,
    data: Field,
}

impl Root {
    fn hash(self) -> Field {
        poseidon2([self.acc, self.data])
    }
}
