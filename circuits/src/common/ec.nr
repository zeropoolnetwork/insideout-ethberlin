use dep::std::ec::tecurve::affine::Curve;
use dep::std::ec::consts::te::baby_jubjub;
use dep::std::ec::sqrt;
use dep::std::hash::poseidon::PoseidonHasher;

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

        let mut hasher = PoseidonHasher::default();
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
fn test_eddsa_verify_0() {
    // Taken from the following data:
    // pk = Point { x: Fr(0x197fdaae6930469533912e344e07e72a3648537c7c84872979216b0feecc66c0), y: Fr(0x2f6466dc2a09a630d8810db1ce67943d27829d9cc8c53ba7b2b964bf9da849cf) }
    // sig = Signature { r_b8: Point { x: Fr(0x213bce1651b35d118a107deb7ad941fd84acb4427fb97f4525574842652106cb), y: Fr(0x13da34bcaf6f215440039e36dbfdc22fe8870aa13519caa22f4c40e637cc4d57) }, s: 2331457278607009735600634377034838521407040039511862771249660037197147222050 }
    // msg = 123456789012345678901234567890
    //
    // Taken from https://github.com/arnaucube/babyjubjub-rs/blob/367ee99d8d15313795aa6e75adbe874c404c7235/src/lib.rs#L565
    let s = SignaturePacked {
        a: 0x197fdaae6930469533912e344e07e72a3648537c7c84872979216b0feecc66c0,
        s: 2331457278607009735600634377034838521407040039511862771249660037197147222050,
        r8: 0x213bce1651b35d118a107deb7ad941fd84acb4427fb97f4525574842652106cb,
    };
    assert(s.verify(123456789012345678901234567890));
}

#[test]
fn test_eddsa_verify_1() {
    // pk = Point { x: Fr(0x10935fd5b96cbecb172faac0eb39c8bf2723657447c4b4eb25e3cdda65a884b2), y: Fr(0x00f95651577b492cc34596c3145ee6c66ea504c81d7c69aa6daf2043d3a71243) }
    // sig = Signature { r_b8: Point { x: Fr(0x28535d59d9066b35df8441c156da49b310523835dedfbf6aea4012d11ce6d931), y: Fr(0x0c77446d64675d55fe2aa49f1d4160ba5a7bed319d63ba7e224eca7620ed0965) }, s: 1426372084044121736122992573070463971308106428625281813611574795316037851300 }
    // msg = 5
    let s = SignaturePacked {
        a: 0x10935fd5b96cbecb172faac0eb39c8bf2723657447c4b4eb25e3cdda65a884b2,
        s: 1426372084044121736122992573070463971308106428625281813611574795316037851300,
        r8: 0x28535d59d9066b35df8441c156da49b310523835dedfbf6aea4012d11ce6d931,
    };
    assert(s.verify(5));
}

// generated with https://github.com/HastilyConceivedCreatures/safecat/
#[test]
fn test_eddsa_verify_2() {
   let s = SignaturePacked {
        a: 11828020974661714696713694513126159991727458242399332189421416923447072843741,
        s: 2025881153938235403708041462012051916442771317472647005053153506543823359806,
        r8: 6487494902383033640348380877452672566142465036218452328715805307268650111091,
    };
    assert(s.verify(8878059966189193382802977823712463973754402735069032857603633822993028222807));
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