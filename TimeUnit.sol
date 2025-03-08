// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract TimeUnit {
    uint256 public startTime;

    function setStartTime() internal {
        startTime = block.timestamp;
    }

    function elapsedSeconds() public view returns (uint256) {
        return block.timestamp - startTime;
    }

    function elapsedMinutes() public view returns (uint256) {
        return (block.timestamp - startTime) / 60;
    }
}
