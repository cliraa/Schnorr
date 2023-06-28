use num_bigint::BigInt;
use std::str::FromStr;

fn ECadd(a: (BigInt, BigInt), b: (BigInt, BigInt)) -> (BigInt, BigInt) {
    let pcurve = BigInt::parse_bytes(b"115792089237316195423570985008687907853269984665640564039457584007908834671663", 10).unwrap();
    let LamAdd: BigInt = ((&b.1 - &a.1) * modinv(&(&b.0 - &a.0), &pcurve)) % (&pcurve);
    let x = ((&LamAdd * &LamAdd) - &a.0 - &b.0) % (&pcurve);
    let y = ((&LamAdd * &(a.0 - &x)) - &a.1) % (&pcurve);

    let x_final = if x < BigInt::from_str("0").unwrap() { x + &pcurve } else { x };
    let y_final = if y < BigInt::from_str("0").unwrap() { y + &pcurve } else { y };

    return (x_final, y_final);

} 

fn ECdouble(a: (BigInt, BigInt)) -> (BigInt, BigInt) {
    let pcurve = BigInt::parse_bytes(b"115792089237316195423570985008687907853269984665640564039457584007908834671663", 10).unwrap();
    let acurve: BigInt = BigInt::from_str("0").unwrap();
    let LamDouble: BigInt = ((3 * &a.0 * &a.0) + &acurve) * modinv(&(&BigInt::from(2) * &a.1), &pcurve) % (&pcurve);
    let x: BigInt = (&LamDouble * &LamDouble - 2 * &a.0) % (&pcurve);
    let y: BigInt = (&LamDouble * (&a.0 - x.clone()) - &a.1) % (&pcurve);

    let x_final = if x < BigInt::from_str("0").unwrap() { x + &pcurve } else { x };
    let y_final = if y < BigInt::from_str("0").unwrap() { y + &pcurve } else { y };

    return (x_final, y_final);
}

fn EccMultiply(GenPoint: (BigInt, BigInt), Scalar: &BigInt) -> (BigInt, BigInt) {
    let pcurve = BigInt::parse_bytes(b"115792089237316195423570985008687907853269984665640564039457584007908834671663", 10).unwrap();
    let n: BigInt = BigInt::parse_bytes(b"115792089237316195423570985008687907852837564279074904382605163141518161494337", 10).unwrap();
    
    if *Scalar == BigInt::from(0) || *Scalar >= n.clone() {
        panic!("Invalid Scalar/Private Key");
    }
    
    let mut scalar_digits: Vec<u8> = Scalar.to_radix_be(2).1;
    scalar_digits.remove(0);
    
    let mut Q: (BigInt, BigInt) = GenPoint.clone();
    
    for i in scalar_digits {
        Q = ECdouble(Q.clone());
        if i == 1 {
            Q = ECadd(Q, GenPoint.clone());
            }
    }
    return Q;
}

fn modinv(a0: &BigInt, m0: &BigInt) -> BigInt {
    let one: BigInt = BigInt::from(1);
    let mut a = a0.clone();
    let mut m = m0.clone();
    let mut x0 = BigInt::from(0);
    let mut inv = BigInt::from(1);

    while a > one {
        inv -= (&a / &m) * &x0;
        a %= &m;
        std::mem::swap(&mut a, &mut m);
        std::mem::swap(&mut x0, &mut inv);
    }
    if inv < BigInt::from(0) {
        inv += m0;
    }
    inv
}

fn main() {
    let generator = (BigInt::parse_bytes(b"55066263022277343669578718895168534326250603453777594175500187360389116729240", 10).unwrap(), BigInt::parse_bytes(b"32670510020758816978083085130507043184471273380659243275938904335757337482424", 10).unwrap());
    let _2G = (BigInt::from_str("89565891926547004231252920425935692360644145829622209833684329913297188986597").unwrap(), BigInt::from_str("12158399299693830322967808612713398636155367887041628176798871954788371653930").unwrap());
    let _scalar = BigInt::from_str("3").unwrap();

    let addition_result = ECadd(generator.clone(), _2G);
    let multiplication_result = EccMultiply(generator.clone(), &_scalar);

    println!("Addition result G + 2G (3G, correct): {:?}", addition_result);
    println!("Multiplication result G * 3 (3G, incorrect): {:?}", multiplication_result);
}
