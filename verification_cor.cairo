//! This module contains functions and constructs related to elliptic curve operations on the
//! secp256k1 curve.

use starknet::{SyscallResult, SyscallResultTrait, secp256_trait::{Secp256Trait, Secp256PointTrait}
};
use option::OptionTrait;
use secp256_trait::{secp256k1_ec_new_syscall, ...}; //importar otras funciones y borrar el resto

#[derive(Copy, Drop)]
extern type Secp256K1EcPoint;

/// Creates a secp256k1 EC point from the given x and y coordinates.
/// Returns None if the given coordinates do not correspond to a point on the curve.
extern fn secp256k1_ec_new_syscall(
    x: u256, y: u256
) -> SyscallResult<Option<Secp256K1EcPoint>> implicits(GasBuiltin, System) nopanic;

/// Computes the addition of secp256k1 EC points `p0 + p1`.
extern fn secp256k1_ec_add_syscall(
    p0: Secp256K1EcPoint, p1: Secp256K1EcPoint
) -> SyscallResult<Secp256K1EcPoint> implicits(GasBuiltin, System) nopanic;

/// Computes the product of a secp256k1 EC point `p` by the given scalar `m`.
extern fn secp256k1_ec_mul_syscall(
    p: Secp256K1EcPoint, m: u256
) -> SyscallResult<Secp256K1EcPoint> implicits(GasBuiltin, System) nopanic;

/// Computes the point on the secp256k1 curve that matches the given `x` coordinate, if such exists.
/// Out of the two possible y's, chooses according to `y_parity`.
extern fn secp256k1_ec_get_point_from_x_syscall(
    x: u256, y_parity: bool
) -> SyscallResult<Option<Secp256K1EcPoint>> implicits(GasBuiltin, System) nopanic;

/// Creates the generator point of the secp256k1 curve.
fn get_generator_point() -> Secp256K1EcPoint {
    secp256k1_ec_new_syscall(
        u256 { high: 0x79be667ef9dcbbac55a06295ce870b07, low: 0x029bfcdb2dce28d959f2815b16f81798 },
        u256 { high: 0x483ada7726a3c4655da4fbfc0e1108a8, low: 0xfd17b448a68554199c47d08ffb10d4b8 }
    )
        .unwrap_syscall()
        .unwrap()
}

fn get_X_point() -> Secp256K1EcPoint {
    secp256k1_ec_new_syscall(
        u256 { high: 0xf1d5bf4c699dc0e31ac0afe94071aa69, low: 0x0bdfebe3f4de82d35ad49da2c59e6d26 },
        u256 { high: 0x6f0af800db9f5ae7f05237c7dbbede94, low: 0x7ec88426dad0d94a0ff3c8be446d590a }
    )
        .unwrap_syscall()
        .unwrap()
}

fn get_R_point() -> Secp256K1EcPoint {
    secp256k1_ec_new_syscall(
        u256 { high: 0x267ee5176ab8b9822e49eaaa1b0c79dd, low: 0xc343900a5fcb78e9b03ec7d1e0719305 },
        u256 { high: 0x8450dd514a51a733e455be7d485f0133, low: 0x8a08b2c6b3ade1e94f0fadd78923041f }
    )

        .unwrap_syscall()
        .unwrap()
}

fn main () {
    let generator_point = get_generator_point();
    let s_scalar = u256 { high: 0x99b48df59941f617c26f4eb7cae3291f, low: 0x08a2fca1aebf54f9f24b973b60390f63 };

    let sG = secp256k1_ec_mul_syscall(generator_point, s_scalar).unwrap_syscall();

    let X_point = get_X_point();
    let e_scalar = u256 { high: 0x605921b06cdec3b8abadac8c6d8a42fc, low: 0xcca7ab57e6c8b0c478dcaafa1b92a91a };

    let eX = secp256k1_ec_mul_syscall(X_point, e_scalar).unwrap_syscall();

    let R_point = get_R_point();
    let R_eX = secp256k1_ec_add_syscall(R_point, eX).unwrap_syscall();

    let (x,y) = secp256k1_get_xy_syscall(sG);
    let (x2,y2) = secp256k1_get_xy_syscall(R_eX);
    if x != x2 || y != y2 {
        panic_with_felt252('error, sG is equal to R_eX')
    }
    //assert(sG != R_eX, 'error, sG is equal to R_eX');
}
