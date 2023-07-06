// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./Base64.sol";
import "./Strings.sol";

contract Hashit {

    function getKeccak256(string memory str) public pure returns(bytes32){
        return keccak256(abi.encodePacked(str));
    }

    function getSha256(string memory str) public  pure  returns (bytes32) {
        return sha256(abi.encodePacked(str));
    }

    function getBase64(string memory str) public pure returns(string memory){
        return Base64.encode(abi.encodePacked(str));
    }

    function getStringHex(uint256 str) public pure returns(string memory){
        return Strings.toHexString(str);
    }

    function getString(uint256 str) public pure returns(string memory){
        return Strings.toString(str);
    }
}
