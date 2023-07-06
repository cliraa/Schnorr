pragma solidity ^0.8.13;

import "./EllipticCurve.sol";

contract Secp256k1 {

  uint256 public constant GX = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
  uint256 public constant GY = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
  uint256 public constant AA = 0;
  uint256 public constant BB = 7;
  uint256 public constant PP = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

function invMod(uint256 val, uint256 p) pure public returns (uint256)
{
    return EllipticCurve.invMod(val,p);
}

function expMod(uint256 val, uint256 e, uint256 p) pure public returns (uint256)
{
    return EllipticCurve.expMod(val,e,p);
}


function getY(uint8 prefix, uint256 x) pure public returns (uint256)
{
    return EllipticCurve.deriveY(prefix,x,AA,BB,PP);
}


function onCurve(uint256 x, uint256 y) pure public returns (bool)
{
    return EllipticCurve.isOnCurve(x,y,AA,BB,PP);
}

function inverse(uint256 x, uint256 y) pure public returns (uint256, 
uint256) {
    return EllipticCurve.ecInv(x,y,PP);
  }

function subtract(uint256 x1, uint256 y1,uint256 x2, uint256 y2 ) pure public returns (uint256, uint256) {
    return EllipticCurve.ecSub(x1,y1,x2,y2,AA,PP);
  }

  function add(uint256 x1, uint256 y1,uint256 x2, uint256 y2 ) pure public returns (uint256, uint256) {
    return EllipticCurve.ecAdd(x1,y1,x2,y2,AA,PP);
  }

function derivePubKey(uint256 privKey) pure public returns (uint256, uint256) {
    return EllipticCurve.ecMul(privKey,GX,GY,AA,PP);
  }
}
