// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract SocialMedia {
    struct User {
        address user;
        address[] subscriptions;
        address[] subscribers;
    }

    mapping(address => User) private users;

    event UserRegistered(address indexed user);
    event SubscriptionAdded(address indexed subscriber, address indexed user);
    event SubscriptionRemoved(address indexed subscriber, address indexed user);

    // function deleteAllUsers() external {
    //     for (uint256 i = 0; i < users.length; i++) {
    //         delete users[i];
    //     }
    // }

    function registerUser() external {
        address user = msg.sender;
        users[user].user = user;
        emit UserRegistered(user);
    }

    function subscribe(address to) external payable {
        address user = msg.sender;
        uint256 amount = msg.value;
        require(user != to, "You cannot subscribe yourself");
        require(users[to].user != address(0), "User does not exist");
        require(amount > 0, "Amount must be greater than 0");
        require(!isSubscribed(to), "You are already subscribed");
        users[user].subscriptions.push(to);
        users[to].subscribers.push(user);
        emit SubscriptionAdded(user, to);
    }

    function unsubscribe(address user) external {
        address subscriber = msg.sender;
        require(user != subscriber, "You cannot unsubscribe yourself");
        require(isSubscribed(subscriber), "You are not subscribed");
        require(users[user].user != address(0), "User does not exist");
        users[subscriber].subscriptions = remove(
            users[subscriber].subscriptions,
            user
        );
        users[user].subscribers = remove(users[user].subscribers, subscriber);
        emit SubscriptionRemoved(subscriber, user);
    }

    function getUserSubscriptions() external view returns (string[] memory) {
        address user = msg.sender;
        string[] memory subscriptions = new string[](
            users[user].subscriptions.length
        );
        for (uint256 i = 0; i < users[user].subscriptions.length; i++) {
            subscriptions[i] = string(
                abi.encodePacked(users[user].subscriptions[i])
            );
        }
        return subscriptions;
    }

    function getUserSubscribers() external view returns (string[] memory) {
        address user = msg.sender;
        string[] memory subscribers = new string[](
            users[user].subscribers.length
        );
        for (uint256 i = 0; i < users[user].subscribers.length; i++) {
            subscribers[i] = string(
                abi.encodePacked(users[user].subscribers[i])
            );
        }
        return subscribers;
    }

    function isSubscribed(address user) public view returns (bool) {
        address subscriber = msg.sender;
        for (uint256 i = 0; i < users[subscriber].subscriptions.length; i++) {
            if (users[subscriber].subscriptions[i] == user) {
                return true;
            }
        }
        return false;
    }

    function remove(
        address[] storage array,
        address element
    ) private returns (address[] storage) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                array[i] = array[array.length - 1];
                array.pop();
                return array;
            }
        }
        return array;
    }
}
