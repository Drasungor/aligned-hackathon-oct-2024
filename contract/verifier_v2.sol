// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

contract TrapTheBugValidator {

    struct RecordHolder {
        uint32 stepsAmount;
        address recordHolder;
        uint32 updatesCounter;
    }

    address public alignedServiceManager;
    address public paymentServiceAddr;
    RecordHolder[] public recordHolders;
    address owner;
    uint32 updatesCounter;

    // TODO: have an owner who can update a stored storedRecordsLimit value
    uint32 public storedRecordsLimit = 10;

    bytes32 public trapTheBugProgramIdCommitment =
        0x745e39c4866b503b4f5dc41ae3a15d4038497f6c80a87644f5789e2bd3e1a8ab;

    event NewRecordHolder(address indexed holder, uint32 newRecord);

    // constructor(uint32 _storedRecordsLimit, address _alignedServiceManager, address _paymentServiceAddr) {
    constructor(address _alignedServiceManager, address _paymentServiceAddr) {
        alignedServiceManager = _alignedServiceManager;
        paymentServiceAddr = _paymentServiceAddr;
        owner = msg.sender;
        // storedRecordsLimit = _storedRecordsLimit;
        updatesCounter = 0;
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
            "Steps amount doesn't match with public input"
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
        uint32 stepsAmount = bytesToUint32(pubInputBytes);
        updateRecordsList(stepsAmount);
        return abi.decode(proofIsIncluded, (bool));
    }

    function bytesToUint32(
        bytes memory data
    ) public pure returns (uint32) {
        require(data.length >= 4, "Input bytes must be at least 4 bytes long");

        uint32 steps_amount = uint32(uint8(data[0])) |
            (uint32(uint8(data[1])) << 8) |
            (uint32(uint8(data[2])) << 16) |
            (uint32(uint8(data[3])) << 24);

        return steps_amount;
    }

    function updateRecordsList(
        uint32 stepsAmount
    ) private {
        uint maxStepsRecordIndex = 0;
        for(uint i = 0; i < recordHolders.length; i++) {
            RecordHolder memory currentRecordHolder = recordHolders[i];
            if (currentRecordHolder.recordHolder == msg.sender) {
                if (currentRecordHolder.stepsAmount > stepsAmount) {
                    recordHolders[i] = RecordHolder(stepsAmount, msg.sender, updatesCounter);
                    updatesCounter++;
                }
                return;
            } else {
                RecordHolder memory replacedRecordHolder = recordHolders[maxStepsRecordIndex];
                if (currentRecordHolder.stepsAmount > replacedRecordHolder.stepsAmount) {
                    maxStepsRecordIndex = i;
                } else if (currentRecordHolder.stepsAmount == replacedRecordHolder.stepsAmount) {
                    if (currentRecordHolder.updatesCounter > replacedRecordHolder.updatesCounter) {
                        maxStepsRecordIndex = i;
                    }
                }
            }
        }

        if (recordHolders.length < storedRecordsLimit) {
            // If the record holders limit was not reached we add a new record holder                
            recordHolders.push(RecordHolder(stepsAmount, msg.sender, updatesCounter));
            updatesCounter++;
            return;
        }

        // If we get here, we iterated the record holders array and got the index of the
        // currently worst and latest record, which is not the same wallet as the caller
        RecordHolder memory worstRecordHolder = recordHolders[maxStepsRecordIndex];
        if (stepsAmount < worstRecordHolder.stepsAmount) {
            recordHolders[maxStepsRecordIndex] = RecordHolder(stepsAmount, msg.sender, updatesCounter);
            updatesCounter++;
        }
    }

    function getRecordHoldersLength() public view returns (uint) {
        return recordHolders.length;
    }
}