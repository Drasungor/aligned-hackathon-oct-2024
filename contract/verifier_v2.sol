// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

contract TrapTheBugRecordsTest {

    struct RecordHolder {
        uint32 stepsAmount;
        address recordHolder;
        uint32 updatesCounter;
    }

    RecordHolder[] public recordHolders;
    address owner;
    uint32 updatesCounter;

    bytes32 public trapTheBugProgramIdCommitment =
        0x745e39c4866b503b4f5dc41ae3a15d4038497f6c80a87644f5789e2bd3e1a8ab;

    event NewRecordHolder(address indexed holder, uint32 newRecord);

    // constructor(uint32 _storedRecordsLimit, address _alignedServiceManager, address _paymentServiceAddr) {
    constructor() {
        owner = msg.sender;
        // storedRecordsLimit = _storedRecordsLimit;
        updatesCounter = 0;

        // TODO: have an owner who can update a stored storedRecordsLimit value
        uint32 storedRecordsLimit = 10;
        for(uint i = 0; i < storedRecordsLimit; i++) {
            recordHolders.push(RecordHolder(type(uint32).max, address(0), updatesCounter));
        }
    }

    function updateRecordsList(
        address receivedAddress, uint32 stepsAmount
    ) public {
        uint maxStepsRecordIndex = 0;
        for(uint i = 0; i < recordHolders.length; i++) {
            RecordHolder memory currentRecordHolder = recordHolders[i];
            if (currentRecordHolder.recordHolder == address(0)) {
                // If the record holders limit was not reached we initialize the next
                // available slot                
                recordHolders[i] = RecordHolder(stepsAmount, receivedAddress, updatesCounter);
                updatesCounter++;
                return;
            } else if (currentRecordHolder.recordHolder == receivedAddress) {
                if (currentRecordHolder.stepsAmount > stepsAmount) {
                    recordHolders[i] = RecordHolder(stepsAmount, receivedAddress, updatesCounter);
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
        // If we get here, we iterated the record holders array and got the index of the
        // currently worst and latest record, which is not the same wallet as the caller
        RecordHolder memory worstRecordHolder = recordHolders[maxStepsRecordIndex];
        if (stepsAmount < worstRecordHolder.stepsAmount) {
            recordHolders[maxStepsRecordIndex] = RecordHolder(stepsAmount, receivedAddress, updatesCounter);
            updatesCounter++;
        }
    }
}