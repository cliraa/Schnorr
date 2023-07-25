//! This module contains functions and constructs related to elliptic curve operations on the
//! secp256k1 curve.

use option::OptionTrait;
use starknet::{
    EthAddress, secp256_trait::{Secp256Trait, Secp256PointTrait}, SyscallResult, SyscallResultTrait
};

#[derive(Copy, Drop)]
extern type Secp256k1Point;

impl Secp256k1Impl of Secp256Trait<Secp256k1Point> {
    // TODO(yuval): change to constant once u256 constants are supported.
    fn get_curve_size() -> u256 {
        0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
    }
    /// Creates the generator point of the secp256k1 curve.
    fn get_generator_point() -> Secp256k1Point {
        secp256k1_new_syscall(
            0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798,
            0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8
        )
            .unwrap_syscall()
            .unwrap()
    }

    fn get_X_point() -> Secp256k1Point {
        secp256k1_new_syscall(
            0xf1d5bf4c699dc0e31ac0afe94071aa690bdfebe3f4de82d35ad49da2c59e6d26,
            0x6f0af800db9f5ae7f05237c7dbbede947ec88426dad0d94a0ff3c8be446d590a
        )
            .unwrap_syscall()
            .unwrap()
    }

    fn get_R_point() -> Secp256k1Point {
        secp256k1_new_syscall(
            0x267ee5176ab8b9822e49eaaa1b0c79ddc343900a5fcb78e9b03ec7d1e0719305,
            0x8450dd514a51a733e455be7d485f01338a08b2c6b3ade1e94f0fadd78923041f
        )
            .unwrap_syscall()
            .unwrap()
    }

    fn get_s() -> u256 {
        0x99b48df59941f617c26f4eb7cae3291f08a2fca1aebf54f9f24b973b60390f63
    }

    fn get_e() -> u256 {
        0x605921b06cdec3b8abadac8c6d8a42fccca7ab57e6c8b0c478dcaafa1b92a91a
    }

    fn secp256_ec_new_syscall(x: u256, y: u256) -> SyscallResult<Option<Secp256k1Point>> {
        secp256k1_new_syscall(x, y)
    }
    fn secp256_ec_get_point_from_x_syscall(
        x: u256, y_parity: bool
    ) -> SyscallResult<Option<Secp256k1Point>> {
        secp256k1_get_point_from_x_syscall(x, y_parity)
    }
}

impl Secp256k1PointImpl of Secp256PointTrait<Secp256k1Point> {
    fn get_coordinates(self: Secp256k1Point) -> SyscallResult<(u256, u256)> {
        secp256k1_get_xy_syscall(self)
    }
    fn add(self: Secp256k1Point, other: Secp256k1Point) -> SyscallResult<Secp256k1Point> {
        secp256k1_add_syscall(self, other)
    }
    fn mul(self: Secp256k1Point, scalar: u256) -> SyscallResult<Secp256k1Point> {
        secp256k1_mul_syscall(self, scalar)
    }
}

/// Creates a secp256k1 EC point from the given x and y coordinates.
/// Returns None if the given coordinates do not correspond to a point on the curve.
extern fn secp256k1_new_syscall(
    x: u256, y: u256
) -> SyscallResult<Option<Secp256k1Point>> implicits(GasBuiltin, System) nopanic;

/// Computes the addition of secp256k1 EC points `p0 + p1`.
extern fn secp256k1_add_syscall(
    p0: Secp256k1Point, p1: Secp256k1Point
) -> SyscallResult<Secp256k1Point> implicits(GasBuiltin, System) nopanic;
/// Computes the product of a secp256k1 EC point `p` by the given scalar `scalar`.
extern fn secp256k1_mul_syscall(
    p: Secp256k1Point, scalar: u256
) -> SyscallResult<Secp256k1Point> implicits(GasBuiltin, System) nopanic;

/// Computes the point on the secp256k1 curve that matches the given `x` coordinate, if such exists.
/// Out of the two possible y's, chooses according to `y_parity`.
/// `y_parity` == true means that the y coordinate is odd.
extern fn secp256k1_get_point_from_x_syscall(
    x: u256, y_parity: bool
) -> SyscallResult<Option<Secp256k1Point>> implicits(GasBuiltin, System) nopanic;

/// Returns the coordinates of a point on the secp256k1 curve.
extern fn secp256k1_get_xy_syscall(
    p: Secp256k1Point
) -> SyscallResult<(u256, u256)> implicits(GasBuiltin, System) nopanic;
