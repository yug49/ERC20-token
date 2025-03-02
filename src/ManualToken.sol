/**
 * @title Manual Token - ERC20
 * @author Yug Agarwal
 * @notice Manual Token built using EPC20 Standards: https://eips.ethereum.org/EIPS/eip-20
 */

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract ManualToken {
    error ManualToken__InsufficientBalance();
    error ManualToken__SendersAllowanceDenied();
    error ManualToken__InvalidReceiver();
    error ManualToken__InvalidOwner();
    error ManualToken__InvalidSender();

    string private constant TOKEN_NAME = "Manual Token";
    string private constant TOKEN_SYMBOL = "MT";
    uint256 private s_totalSupply;
    uint8 private constant DECIMALS = 8;

    mapping(address owner => uint256 balance) private s_balances;
    mapping(address owner => mapping(address sender => uint256 ammountAllowed)) private s_allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TansferFromApproved(address indexed from, address indexed sender, address indexed to, uint256 value);
    event MintSuccesfull(address indexed to, uint256 value);
    event BurnSuccessfull(address indexed from, uint256 value);
    event MintSuccessfull(address indexed to, uint256 value);

    constructor (uint256 _value){
        mint(msg.sender, _value);
    }

    function name() public pure returns (string memory) {
        return TOKEN_NAME;
    }

    function symbol() public pure returns (string memory) {
        return TOKEN_SYMBOL;
    }

    function totalSupply() public view returns (uint256) {
        return s_totalSupply;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function getBalance(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _value) public {
        if(msg.sender == address(0)) revert ManualToken__InvalidSender();
        if(_to == address(0)) revert ManualToken__InvalidReceiver();
        if (s_balances[msg.sender] < _value) {
            revert ManualToken__InsufficientBalance();
        }
        emit Transfer(msg.sender, _to, _value);

        s_balances[_to] += _value;
        unchecked {
            s_balances[msg.sender] -= _value;
        }
    }

    function approve(
        address _from,
        address _sender,
        uint256 _value,
        address _to
    ) private returns (bool) {
        if (s_allowances[_from][_sender] < _value) {
            return false;
        } else {
            emit TansferFromApproved(_from, _sender, _to, _value);
            return true;
        }
    }

    function transferFrom(address _owner, address _to, uint256 _value) public {
        if(msg.sender == address(0)) revert ManualToken__InvalidSender();
        if(_to == address(0)) revert ManualToken__InvalidReceiver();
        if(_owner == address(0)) revert ManualToken__InvalidOwner();
        if (!approve(_owner, msg.sender, _value, _to)) {
            revert ManualToken__SendersAllowanceDenied();
        }
        if (s_balances[_owner] < _value) {
            revert ManualToken__InsufficientBalance();
        }
        emit Transfer(_owner, _to, _value);
        unchecked {
            s_allowances[_owner][msg.sender] -= _value;
            s_balances[_owner] -= _value;
        }
        s_balances[_to] += _value;
    }

    function allowance(address _to, uint256 _ammountAllowed) public {
        if(msg.sender == address(0)) revert ManualToken__InvalidSender();
        if(_to == address(0)) revert ManualToken__InvalidReceiver();
        
        s_allowances[msg.sender][_to] = 0;
        s_allowances[msg.sender][_to] = _ammountAllowed;
    }

    function mint(address _to, uint256 _value) internal {
        if(_to == address(0)) revert ManualToken__InvalidReceiver();
        if(msg.sender == address(0)) revert ManualToken__InvalidSender();
        update(address(0), _to, _value);
    }

    function burn(address _from, uint256 _value) internal {
        if(_from == address(0)) revert ManualToken__InvalidSender();
        if(msg.sender == address(0)) revert ManualToken__InvalidReceiver();
        update(_from, address(0), _value);
    }

    function update(address _from , address _to, uint256 _value) private {
        if(_to == address(0)) {
            unchecked{
                s_totalSupply -= _value;
                s_balances[_from] -= _value;
            }
            emit BurnSuccessfull(_from, _value);
        }
        s_totalSupply += _value;
        s_balances[_to] += _value;
        emit MintSuccessfull(_to, _value);
    }

    function getAllowances(address _owner, address _sender) public view returns(uint256){
        return s_allowances[_owner][_sender];
    }
}
