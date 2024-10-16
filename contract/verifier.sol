// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

contract TrapTheBugValidator {

    struct RecordHolder {
        uint32 minValue;
        address recordHolder;
    }

    address public alignedServiceManager;
    address public paymentServiceAddr;
    bytes32 public fibonacciProgramId;
    RecordHolder public recordHolder;

    // Update program commitment
    bytes32 public trapTheBugProgramIdCommitment =
        0x069ed9f3972550a2901523723f4beb5e240749dcafa30e1623d0778e17d69d70;

    // event FibonacciNumbers(uint32 fibN, uint32 fibNPlusOne);
    event NewRecordHolder(address indexed holder, uint32 newRecord);

    constructor(address _alignedServiceManager, address _paymentServiceAddr) {
        alignedServiceManager = _alignedServiceManager;
        paymentServiceAddr = _paymentServiceAddr;
        recordHolder = RecordHolder(type(uint32).max, address(0));
    }

    function verifyBatchInclusion(
        bytes32 proofCommitment,
        bytes32 pubInputCommitment,
        bytes32 programIdCommitment,
        bytes20 proofGeneratorAddr,
        bytes32 batchMerkleRoot,
        bytes memory merkleProof,
        uint256 verificationDataBatchIndex,
        bytes memory pubInputBytes
    ) public returns (bool) {
        require(
            trapTheBugProgramIdCommitment == programIdCommitment,
            "Program ID doesn't match"
        );

        require(
            pubInputCommitment == keccak256(abi.encodePacked(pubInputBytes)),
            "Fibonacci numbers don't match with public input"
        );

        (
            bool callWasSuccessful,
            bytes memory proofIsIncluded
        ) = alignedServiceManager.staticcall(
                abi.encodeWithSignature(
                    "verifyBatchInclusion(bytes32,bytes32,bytes32,bytes20,bytes32,bytes,uint256,address)",
                    proofCommitment,
                    pubInputCommitment,
                    programIdCommitment,
                    proofGeneratorAddr,
                    batchMerkleRoot,
                    merkleProof,
                    verificationDataBatchIndex,
                    paymentServiceAddr
                )
            );

        require(callWasSuccessful, "static_call failed");

        uint32 steps_amount = bytesToUint32(pubInputBytes);

        // emit FibonacciNumbers(fibN, fibNPlusOne);
        if (steps_amount < recordHolder.minValue) {
            recordHolder.recordHolder = msg.sender;
            recordHolder.minValue = steps_amount;
            emit NewRecordHolder(msg.sender, steps_amount);
        }

        return abi.decode(proofIsIncluded, (bool));
    }

    function bytesToUint32(
        bytes memory data
    ) public pure returns (uint32) {
        require(data.length >= 8, "Input bytes must be at least 8 bytes long");

        uint32 steps_amount = uint32(uint8(data[0])) |
            (uint32(uint8(data[1])) << 8) |
            (uint32(uint8(data[2])) << 16) |
            (uint32(uint8(data[3])) << 24);

        return steps_amount;
    }
}