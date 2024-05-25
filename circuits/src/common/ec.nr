use dep::std::ec::tecurve::affine::Curve;
use dep::std::ec::consts::te::baby_jubjub;
use dep::std::ec::sqrt;
use dep::std::hash::poseidon2::Poseidon2Hasher;

use dep::std::ec::tecurve::affine::Point;
use dep::std::eddsa::eddsa_verify_with_hasher;



struct SignaturePacked {
    a: Field,
    s: Field,
    r8: Field
}

impl SignaturePacked {
    pub fn verify(self, msg:Field) -> bool {
        let a = subgroup_decompress(self.a);
        let r8 = subgroup_decompress(self.r8);

        let mut hasher = Poseidon2Hasher::default();
        eddsa_verify_with_hasher(a.x, a.y, self.s, r8.x, r8.y, msg, &mut hasher)
    }
}


pub fn subgroup_decompress(x: Field) -> Point {
    let bjj = baby_jubjub();
    let p = subgroup_decompress_one_eighth(x);

    assert(bjj.curve.contains(p));
    
    let p8 = bjj.curve.mul(8, p);
    assert(p8.x == x);

    p8
}


unconstrained fn subgroup_decompress_one_eighth(x: Field) -> Point {
    let one_eighth: Field = 2394026564107420727433200628387514462817212225638746351800188703329891451411;
    let bjj = baby_jubjub();
    
    let x2 = x * x;
    let nom = 1 - bjj.curve.a * x2;
    let denom = 1 - bjj.curve.d * x2;
    let y = sqrt(nom / denom);

    let p = Point::new(x, y);
    
    let Point {x:lx, y:ly} = bjj.curve.mul(bjj.suborder , p);

    let res = if lx == 0 {
        if ly == 1 {
            Point::new(x, y)
        } else {
            Point::new(x, -y)
        }
    } else {
        // Send wrong value to fail the check in the circuit
        Point::new(0, 1)
    };

    bjj.curve.mul(one_eighth, res)
}


#[test]
fn test_subgroup_decompress_valid_points() {
    let bjj = baby_jubjub();
   

    let scalars = [42, 1337, 9876543210];

    for scalar in scalars {
        let p = bjj.curve.mul(scalar, bjj.base8);
        let decomp_p = subgroup_decompress(p.x);

        assert(decomp_p.x == p.x);
        assert(decomp_p.y == p.y);
    }
}

#[test(should_fail)]
fn test_subgroup_decompress_invalid_point() {

    let invalid_x = 124;
    let decomp_p = subgroup_decompress(invalid_x);


    assert(decomp_p.x == invalid_x);
}