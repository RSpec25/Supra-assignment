// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    address[] public owners; //array of owners
    mapping(address => bool) public isOwner; //for checking ownership faster

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }
    Transaction[] public transactions;
    uint public required; //min required approval

    // mapping from tx index => owner => bool
    // owner can approve transaction by passing index
    mapping(uint => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notApproved(uint _txIndex) {
        require(!approved[_txIndex][msg.sender], "tx already approved");
        _;
    }

    constructor(address[] memory _owners, uint _require) {
        require(_owners.length > 0, "not enough owners of the wallet");
        require(
            _require > 0 && _require <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint i; i < _owners.length; ++i) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _require;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(
        address _to,
        uint _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );
        emit Submit(transactions.length - 1);
    }

    function approve(
        uint _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) notApproved(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function getApprovalCount(uint _txId) private view returns (uint count) {
        for (uint i; i < owners.length; ++i) {
            if (approved[_txId][owners[i]]) {
                count = count + 1;
            }
        }
        return count;
    }

    function executeTransaction(
        uint _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) {
        Transaction storage transaction = transactions[_txId];
        require(getApprovalCount(_txId) >= required, "cannot execute tx");
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");
        emit Execute(_txId);
    }

    function revokeConfirmation(
        uint _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "tx not approved before");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}
