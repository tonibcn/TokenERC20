// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";



//Juan Gabriel ---> 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Juan Amengual ---> 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//María Santos ---> 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

//1. Interface de nuestro token ERC20
interface IERC20{
    //1.1 Functions
    //It returns us the total supply of our token
    function totalSupply() external view returns (uint256);

    //Returs number of tokens from a certain address
    function balanceOf(address account) external view returns (uint256);

    //Returns number of tokens that one address can spend from other address
    function allowance(address owner, address spender) external view returns (uint256);

    //Confirms that a transfer is done
    function transfer(address recipient, uint256 amount) external returns (bool);

    //Approve spender transaction
    function approve(address spender, uint256 amount) external returns (bool);

    //Return result of transfer from one adrress to another
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    //1.2 Events
    //Event emited when we transfer from one adrress to another
    event Transfer(address indexed from, address indexed to, uint256 value);

    //Event emited when we allow someone can spend our tokens
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// 2 Smart contract
//We apply our functions to our contract
contract ERC20Basic is IERC20{
    //2.1 Variables
        string public constant name = "ERC20BlockchainTDR";
        string public constant symbol = "ERC";
        //Maxim number of decimals will be 18
        uint8 public constant decimals = 18;

    //2.2 This events ara available in this contract
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);

    //To avoid overflow we use safemath library
    using SafeMath for uint256;

    //2.3 Mappings
    //Private variables; anyone can modify
    mapping (address => uint) balances;
    //We used a mapping of mapping: Ex one addres mine 10 ETH and we need to know every addres how much ETH belong
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;
    //2.4 Constructor
    //First, creator will have all supply except the tokens
    constructor (uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    //2.5 Functions definition
    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }

    //New function to create new tokens when we mine
    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    }
    // Event to transfer tokens directly
    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        //First we make sure have enought tokens
        require(numTokens <= balances[msg.sender]);
        //Then we substract from our address to the addrees
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        //We need to notify 
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }

    //Event to approve that delegate use my tokens
    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    //Transfer when we are the delegate of some tokens
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        //Owner have to have the number of tokens
        require(numTokens <= balances[owner]);
        //As delegate we have to have permissions to transfer tokens
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}