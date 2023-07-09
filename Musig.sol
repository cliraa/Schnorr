pragma solidity ^0.8.13; 
 
import "./EllipticCurve.sol"; 
import "./Base64.sol"; 
import "./Strings.sol"; 
 
contract Schnorr { 
 
  uint256 public constant GX = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798; 
  uint256 public constant GY = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8; 
  uint256 public constant AA = 0; 
  uint256 public constant BB = 7; 
  uint256 public constant PP = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F; 
 
  uint256 private alicePrivateKey; 
  uint256 private bobPrivateKey; 
  uint256 private aliceNonce; 
  uint256 private bobNonce; 
 
  function setAlicePrivateKey(uint256 _privKey) public { 
    alicePrivateKey = _privKey; 
  } 
 
  function setBobPrivateKey(uint256 _privKey) public { 
    bobPrivateKey = _privKey; 
  } 
 
  function setAliceNonce(uint256 _AliceNonce) public { 
    aliceNonce = _AliceNonce; 
  } 
 
  function setBobNonce(uint256 _BobNonce) public { 
    bobNonce = _BobNonce; 
  } 
 
  function AderivePubKeyAlice() view public returns (uint256, uint256) { 
    return EllipticCurve.ecMul(alicePrivateKey, GX, GY, AA, PP); 
  } 
 
  function BderivePubKeyBob() view public returns (uint256, uint256) { 
    return EllipticCurve.ecMul(bobPrivateKey, GX, GY, AA, PP); 
  } 
 
  function CderiveNonceAlice() view public returns (uint256, uint256) { 
    return EllipticCurve.ecMul(aliceNonce, GX, GY, AA, PP); 
  } 
 
  function DderiveNonceBob() view public returns (uint256, uint256) { 
    return EllipticCurve.ecMul(bobNonce, GX, GY, AA, PP); 
  } 
 
  function EaggregatedPublicNonce() public view returns (uint256, uint256) { 
    (uint256 px1, uint256 py1) = CderiveNonceAlice(); 
    (uint256 px2, uint256 py2) = DderiveNonceBob(); 
    return EllipticCurve.ecAdd(px1, py1, px2, py2, AA, PP); 
  } 
 
  function sumAndHash(uint256 a, uint256 b) public pure returns(bytes32) { 
    bytes memory data = abi.encodePacked(a, b); 
    bytes32 hashResult = sha256(data); 
    return hashResult; 
  } 
  
  function calculateHashAndSum() public view returns (uint256) { 
    (uint256 aliceX, ) = AderivePubKeyAlice(); 
    (uint256 bobX, ) = BderivePubKeyBob(); 
    bytes32 hashResult = sumAndHash(aliceX, bobX); 
 
    uint256 decimalResult = 0; 
    for (uint256 i = 0; i < 32; i++) { 
      decimalResult += uint256(uint8(hashResult[i])) * (2**(8 * (32 - i - 1))); 
    } 
 
    return decimalResult; 
  } 
 
  function calculateFinalHash() public view returns (uint256) {
    (uint256 aliceX, ) = AderivePubKeyAlice(); 
    uint256 decimalResult = calculateHashAndSum();
    bytes32 hashResult = sumAndHash(decimalResult, aliceX);

    uint256 decimalFinalResult = 0;
    for (uint256 i = 0; i < 32; i++) {
      decimalFinalResult += uint256(uint8(hashResult[i])) * (2**(8 * (32 - i - 1)));
    }

    return decimalFinalResult;
  }

  function calculateFinalHash2() public view returns (uint256) {
    (uint256 bobX, ) = BderivePubKeyBob(); 
    uint256 decimalResult = calculateHashAndSum();
    bytes32 hashResult = sumAndHash(decimalResult, bobX);

    uint256 decimalFinalResult2 = 0;
    for (uint256 i = 0; i < 32; i++) {
      decimalFinalResult2 += uint256(uint8(hashResult[i])) * (2**(8 * (32 - i - 1)));
    }

    return decimalFinalResult2;
  }

  function calculatexa() view public returns (uint256, uint256) { 
    uint256 decimalResult = calculateFinalHash();  
 
    (uint256 XCoor, uint256 YCoor) = AderivePubKeyAlice();
  
    return EllipticCurve.ecMul(decimalResult, XCoor, YCoor, AA, PP);
  }

  function calculatexb() view public returns (uint256, uint256) {
    (uint256 bobX, uint256 bobY) = BderivePubKeyBob();

    uint256 decimalResult = calculateFinalHash2();

    return EllipticCurve.ecMul(decimalResult, bobX, bobY, AA, PP);
  }

  function generatex() public view returns (uint256, uint256) {
    (uint256 xa, uint256 ya) = calculatexa();
    (uint256 xb, uint256 yb) = calculatexb();

    return EllipticCurve.ecAdd(xa, ya, xb, yb, AA, PP);
  }

}
