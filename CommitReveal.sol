// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract CommitReveal {
    struct Commit {
        bytes32 commit;
        uint64 blockNumber;
        bool revealed;
    }

    mapping(address => Commit) public commits;

    event CommitHash(address sender, bytes32 dataHash, uint64 blockNumber);
    event RevealHash(address sender, bytes32 revealHash);

    function commit(bytes32 dataHash) public {
        commits[msg.sender] = Commit(dataHash, uint64(block.number), false);
        emit CommitHash(msg.sender, dataHash, commits[msg.sender].blockNumber);
    }

    function reveal(bytes32 revealHash) public {
        require(!commits[msg.sender].revealed, "Already revealed");
        require(getHash(revealHash) == commits[msg.sender].commit, "Hash mismatch");
        require(block.number > commits[msg.sender].blockNumber, "Same block reveal not allowed");
        require(block.number <= commits[msg.sender].blockNumber + 250, "Reveal too late");

        commits[msg.sender].revealed = true;
        emit RevealHash(msg.sender, revealHash);
    }

    function getHash(bytes32 data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }
}
