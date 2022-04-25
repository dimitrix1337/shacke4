// SPDX-License-Identifier: NONE

pragma solidity ^ 0.8.11;

/// @title RapiDrive highway simulator
/// @author Shacker4
/// @dev This functions are for test if the interface is the correct.

interface IRapiDrive {

    /// @notice Calculate the cost of a determinate ramp
    /// @param name of the ramp which will be created
    /// @param location of the ramp which will be created
    /// @param price of the ramp which will be created
    function create_ramp(string memory name, string memory location, uint price) external;

    /// @notice Check allowance from user
    /// @param name of the ramp to use
    function use_ramp(string memory name) external;

    /// @notice Check allowance from user
    /// @return if the user has enough RPD TOKEN to use highway
    function check_allowance() external view returns(bool);

    /// @notice function to pay ramps after calculate cost and check if the driver has 10 rpd tokens.
    function pay_ramp() external;

}