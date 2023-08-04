use core::clone::Clone;
use array::ArrayTrait;
use core::traits::Into;
//use starknet::SyscallResultTrait;
use test::test_utils::{assert_eq, assert_ne};

use option::OptionTrait;
use starknet::secp256k1::{secp256k1_new_syscall, Secp256k1Point};
use starknet::secp256_trait::{Secp256Trait, Secp256PointTrait};
use starknet::{SyscallResult, SyscallResultTrait};

use debug::PrintTrait;

// Generator Point:

fn get_generator_point() -> Secp256k1Point {
    secp256k1_new_syscall(
        0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798,
        0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8
    )
        .unwrap_syscall()
        .unwrap()
}

// Curve Size:

fn get_curve_size() -> u256 {
        0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
    }

// Private Keys:

fn Alice_PrivKey() -> u256 {
    0x2
}

fn Bob_PrivKey() -> u256 {
    0x3
}

// Nonces:

fn Alice_Nonce() -> u256 {
    0x4
}

fn Bob_Nonce() -> u256 {
    0x5
}

#[test]
#[available_gas(100000000)]
fn signature() {

    // Generator:

    let (Gx, Gy) = get_generator_point().get_coordinates().unwrap_syscall();

    // Privates Keys:

    let Alice_PrivKey = Alice_PrivKey();
    let Bob_PrivKey  = Bob_PrivKey();

    //Public Keys:

    let gx_gy = secp256k1_new_syscall(Gx,Gy).unwrap_syscall().unwrap();

    let Alice_PublicKey = gx_gy.mul(Alice_PrivKey).unwrap_syscall();
    let Bob_PublicKey = gx_gy.mul(Bob_PrivKey).unwrap_syscall();

    // Nonces:

    let Alice_Nonce = Alice_Nonce();
    let Bob_Nonce  = Bob_Nonce();

    // Public Nonce:

    let Alice_PublicNonce = gx_gy.mul(Alice_Nonce).unwrap_syscall();
    let Bob_PublicNonce = gx_gy.mul(Bob_Nonce).unwrap_syscall();

    // Aggretaged Public Nonce:
    
    let R = Alice_PublicNonce.add(Bob_PublicNonce).unwrap_syscall();

    // Hash of the public key set:

    let (P_x_Alice, P_y_Alice) = Alice_PublicKey.get_coordinates().unwrap_syscall();
    let (P_x_Bob, P_y_Bob) = Bob_PublicKey.get_coordinates().unwrap_syscall();

    let l = keccak::keccak_u256s_be_inputs(array![P_x_Alice, P_x_Bob].span());

    // Weight factor:

    let w_a = keccak::keccak_u256s_be_inputs(array![l, P_x_Alice].span());
    let w_b = keccak::keccak_u256s_be_inputs(array![l, P_x_Bob].span());

    // Aggretaged public key:

    let X_1 = Alice_PublicKey.mul(w_a).unwrap_syscall();
    let X_2 = Bob_PublicKey.mul(w_b).unwrap_syscall();

    let X = X_1.add(X_2).unwrap_syscall();    

    // Challenge e:

    let (R_x_aggregated, R_y_aggregated) = R.get_coordinates().unwrap_syscall();
    let (X_x_aggretaged, X_y_aggregated) = X.get_coordinates().unwrap_syscall();

    let e = keccak::keccak_u256s_be_inputs(array![R_x_aggregated, X_x_aggretaged].span());

    // Signature:

    let s_a = (Alice_Nonce() + (Alice_PrivKey() * w_a * e)) % get_curve_size();
    let s_b = (Bob_Nonce() + (Bob_PrivKey() * w_b * e)) % get_curve_size();

    // Aggregated Signature:

    let s = (s_a + s_b) % get_curve_size();

    // Verification:

    let sG = gx_gy.mul(s).unwrap_syscall();

    let xx_yy = secp256k1_new_syscall(X_x_aggretaged, X_y_aggregated).unwrap_syscall().unwrap();
    let eX = xx_yy.mul(e).unwrap_syscall();
    
    let rx_ry = secp256k1_new_syscall(R_x_aggregated, R_y_aggregated).unwrap_syscall().unwrap();
    let R_eX = rx_ry.add(eX).unwrap_syscall();
    
    let (x, y) = sG.get_coordinates().unwrap_syscall();
    let (x2, y2) = R_eX.get_coordinates().unwrap_syscall();
    
    'sG'.print();
    x.print();
    y.print();

    'R_eX'.print();
    x2.print();
    y2.print();
    
    if x != x2 || y != y2 {
        panic_with_felt252('error, sG is equal to R_eX')
    }  

}
