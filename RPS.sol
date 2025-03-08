// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./CommitReveal.sol";
import "./TimeUnit.sol";

contract RPS is CommitReveal, TimeUnit {
    uint public numPlayer = 0;
    uint public reward = 0;
    mapping(address => bytes32) public player_commit;
    mapping(address => bool) public player_not_played;
    address[] public players;
    uint public numInput = 0;
    mapping(address => uint) public player_choice;
    mapping(address => bool) public hasWithdrawn;
    uint256 public gameStartTime;

    address[4] allowedAccounts = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    ];

    // Constructor that allows the contract to accept Ether
    constructor() payable {
        // constructor logic here if needed
    }

    modifier onlyAllowed() {
        bool isAllowed = false;
        for (uint i = 0; i < allowedAccounts.length; i++) {
            if (msg.sender == allowedAccounts[i]) {
                isAllowed = true;
                break;
            }
        }
        require(isAllowed, "Not an allowed player");
        _;
    }

    function addPlayer(bytes32 commitHash) public payable onlyAllowed {
        require(numPlayer < 2, "Game full");
        require(msg.value == 1 ether, "Must send 1 ETH");
        require(!player_not_played[msg.sender], "Already joined");
        
        if (numPlayer > 0) {
            require(msg.sender != players[0], "Duplicate player");
        }

        reward += msg.value;
        player_not_played[msg.sender] = true;
        players.push(msg.sender);
        player_commit[msg.sender] = commitHash;
        numPlayer++;
        
        if (numPlayer == 2) {
            setStartTime();
        }
    }

    function revealChoice(bytes32 revealHash, uint choice) public onlyAllowed {
        require(player_not_played[msg.sender], "Already revealed");
        require(getHash(revealHash) == player_commit[msg.sender], "Invalid reveal");
        require(choice >= 0 && choice <= 4, "Invalid choice");

        player_choice[msg.sender] = choice;
        player_not_played[msg.sender] = false;
        numInput++;
        
        if (numInput == 2) {
            _checkWinnerAndPay();
        }
    }

    function _checkWinnerAndPay() private {
        uint p0Choice = player_choice[players[0]];
        uint p1Choice = player_choice[players[1]];
        address payable account0 = payable(players[0]);
        address payable account1 = payable(players[1]);

        if ((p0Choice + 1) % 5 == p1Choice || (p0Choice + 3) % 5 == p1Choice) {
            account1.transfer(reward);
        } else if ((p1Choice + 1) % 5 == p0Choice || (p1Choice + 3) % 5 == p0Choice) {
            account0.transfer(reward);
        } else {
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
        _resetGame();
    }

    function withdraw() public onlyAllowed {
        require(numPlayer == 1 && elapsedMinutes() >= 5, "Cannot withdraw yet");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");
        payable(msg.sender).transfer(reward);
        hasWithdrawn[msg.sender] = true;
        _resetGame();
    }

    function _resetGame() private {
        // Reset mappings manually
        for (uint i = 0; i < players.length; i++) {
            player_commit[players[i]] = bytes32(0); // Reset the commit hash
            player_choice[players[i]] = 0; // Reset player choices
            player_not_played[players[i]] = true; // Reset played status
        }

        // Reset other variables
        delete players;
        delete numInput;
        delete numPlayer;
        delete reward;
        delete gameStartTime;
    }
}
