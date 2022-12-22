// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//Goerli ağı için
contract VRFWorkshop is VRFConsumerBaseV2, Ownable {
    uint64 s_subscriptionId;
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    //Her sayı için 20000 gas. 
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    VRFCoordinatorV2Interface COORDINATOR;

    address[] public katilimcilar;
    address public kazanan;
    bool public yarismaBitti;

    uint256 public randomNumber;
    
    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
    {
        COORDINATOR = VRFCoordinatorV2Interface(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);
        s_subscriptionId = subscriptionId;
    }

    function requestRandomWords() internal {
        COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        randomNumber = _randomWords[0];
        kazanan = katilimcilar[_randomWords[0] % katilimcilar.length];
        yarismaBitti = true;
    }

    function yarismayaKatil() external payable {
        require(!yarismaBitti, "Yarisma bitti");
        require(msg.value == 0.001 ether, "0.001 ether gondermelisiniz");
        katilimcilar.push(msg.sender);
    }

    function kazananiBelirle() external onlyOwner {
        requestRandomWords();   
    }

    function paraCek() external {
        require(msg.sender == kazanan);
        (bool sonuc, ) = kazanan.call{value: address(this).balance}("");
        require(sonuc);
    }
    
}