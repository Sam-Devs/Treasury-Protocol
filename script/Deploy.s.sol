// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "contracts/Treasury.sol";

contract TreasuryScript is Script {
    Treasury treasury;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        treasury = new Treasury(50,50);
        vm.stopBroadcast();
    }
}
