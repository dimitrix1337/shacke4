// SPDX-License-Identifier: NONE

pragma solidity ^ 0.8.11;

/// @title RapiDrive highway simulator
/// @author Shacker4
/// @dev This functions are for test if the interface is the correct.

interface IRapiDrive {

    /// @notice Calculate the cost of a determinate ramp
    /// @param name of the ramp which will be created
    /// @param location of the ramp which will be created
    function create_ramp(string memory name, string memory location) external;

    /// @notice create a route between two ramps
    /// @param name of the route which will be created
    /// @param entry name of the ramp which will be paired
    /// @param exit name of the ramp which will be paired
    /// @param price of the route which will be created
    function create_route(string memory name, string memory entry, string memory exit, uint price) external;

    /// @notice Check allowance from user
    /// @param route_name name of the route to use
    function use_route(string memory route_name) external;

    /// @notice Check allowance from user
    /// @return if the user has enough RPD TOKEN to use highway
    function check_allowance() external view returns(bool);

    /// @notice function to pay route after calculate cost and check if the driver has 10 rpd tokens.
    function pay_route() external;

}