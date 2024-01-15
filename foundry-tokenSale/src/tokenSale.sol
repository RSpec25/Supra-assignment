//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract createToken is ERC20, Ownable {
    constructor(
        string memory name,
        string memory sym,
        address initialOwner
    ) ERC20(name, sym) Ownable(initialOwner) {}

    function mint(uint amount, address accnt) external {
        _mint(accnt, amount);
    }
}

contract tokenSale is Ownable {
    createToken public token;
    uint256 public constant minContribution = 10 * 1e18;
    // address owner;
    // presale variables
    uint256 public presaleCap;
    uint256 public presaleMinContribution;
    uint256 public presaleMaxContribution;
    bool public presaleActive;
    uint256 totalPresale;
    uint256 totalPublicsale;

    // public sale variables
    uint256 public publicSaleCap;
    uint256 public publicSaleMinContribution;
    uint256 public publicSaleMaxContribution;
    bool public publicSaleActive;

    mapping(address => uint256) public presaleContributions;
    mapping(address => uint256) public publicSaleContributions;

    event PresaleContribution(address indexed participant, uint256 amount);
    event PublicSaleContribution(address indexed participant, uint256 amount);

    modifier refund() {
        require(
            totalPresale < minContribution || totalPublicsale < minContribution
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _presaleCap,
        uint256 _publicSaleCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution,
        address initialOwner
    ) Ownable(initialOwner) {
        // owner=initialOwner;
        token = new createToken(_name, _symbol, initialOwner);
        require(
            presaleMinContribution < presaleMaxContribution &&
                publicSaleMinContribution < publicSaleMaxContribution,
            "please add contribution carefully"
        );

        presaleCap = _presaleCap;
        publicSaleCap = _publicSaleCap;
        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;
        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;
    }

    function startPresale() external onlyOwner {
        require(!presaleActive, "Presale is already active");
        presaleActive = true;
    }

    function endPresale() external onlyOwner {
        require(presaleActive, "Presale is not active");
        presaleActive = false;
        publicSaleActive = true;
    }

    function contributeToPresale() external payable {
        require(presaleActive, "Presale is not active");
        require(
            msg.value >= presaleMinContribution,
            "Below minimum contribution"
        );
        require(
            presaleContributions[msg.sender] + msg.value <=
                presaleMaxContribution,
            "Exceeds maximum contribution"
        );
        require(
            address(this).balance + msg.value <= presaleCap,
            "Exceeds presale cap"
        );

        uint256 tokenAmount = msg.value;
        token.mint(tokenAmount, msg.sender);

        presaleContributions[msg.sender] += msg.value;
        totalPresale = totalPresale + tokenAmount;

        emit PresaleContribution(msg.sender, msg.value);
    }

    function contributeToPublicSale() external payable {
        require(publicSaleActive, "Public sale is not active");
        require(
            msg.value >= publicSaleMinContribution,
            "Below minimum contribution"
        );
        require(
            publicSaleContributions[msg.sender] + msg.value <=
                publicSaleMaxContribution,
            "Exceeds maximum contribution"
        );
        require(
            address(this).balance + msg.value <= publicSaleCap,
            "Exceeds public sale cap"
        );

        uint256 tokenAmount = msg.value;
        token.mint(tokenAmount, msg.sender);

        publicSaleContributions[msg.sender] += msg.value;
        totalPublicsale = totalPublicsale + tokenAmount;

        emit PublicSaleContribution(msg.sender, msg.value);
    }

    function endPublicSale() external onlyOwner {
        require(publicSaleActive, "Public sale is not active");
        publicSaleActive = false;
    }

    // Function to distribute project tokens to a specified address
    function distributeTokens(
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(
            !presaleActive && !publicSaleActive,
            "Cannot distribute tokens during active sale"
        );
        token.mint(amount, recipient);
    }

    // Function to claim a refund if the minimum cap for either sale is not reached
    function claimRefund() external refund {
        //reentrency attack possible
        require(
            !presaleActive && !publicSaleActive,
            "Cannot claim refund during active sale"
        );
        uint256 contribution = presaleContributions[msg.sender] +
            publicSaleContributions[msg.sender];
        require(contribution > 0, "No contributions found");

        // Reset the contribution records before transfering the fund,protecting against reentrency
        presaleContributions[msg.sender] = 0;
        publicSaleContributions[msg.sender] = 0;

        // Logic to refund the contributor
        payable(msg.sender).transfer(contribution);
    }
}

// "bro","BRO",5e18,5e18,1e18,3e18,1e18,3e18,0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
