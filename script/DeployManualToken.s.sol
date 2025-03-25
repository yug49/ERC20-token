// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {ManualToken} from "../src/ManualToken.sol";

contract DeployManualToken is Script {
    uint256 private constant INITIAL_AMOUNT = 100 ether;
    ManualToken public manualToken;

    function run() public returns (ManualToken) {
        vm.startBroadcast();
        manualToken = deploy();
        vm.stopBroadcast();

        return manualToken;
    }

    function deploy() private returns (ManualToken) {
        manualToken = new ManualToken(INITIAL_AMOUNT);
        return manualToken;
    }
}
