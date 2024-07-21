// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 ^0.8.24;

// lib/evm-contracts/i_cosmos/ICosmos.sol

/// @dev The ICosmos contract's address.
address constant COSMOS_ADDRESS = 0x00000000000000000000000000000000000000f1;

/// @dev The ICosmos contract's instance.
ICosmos constant COSMOS_CONTRACT = ICosmos(COSMOS_ADDRESS);

interface ICosmos {
    // check if an address is blocked in bank module
    function is_blocked_address(address account) external view returns (bool blocked);

    // check if an address is a module account
    function is_module_address(address account) external view returns (bool module);

    // convert an EVM address to a Cosmos address
    function to_cosmos_address(
        address evm_address
    ) external returns (string memory cosmos_address);

    // convert a Cosmos address to an EVM address
    function to_evm_address(
        string memory cosmos_address
    ) external returns (address evm_address);

    // convert an ERC20 address to a Cosmos denom
    function to_denom(
        address erc20_address
    ) external returns (string memory denom);

    // convert a Cosmos denom to an ERC20 address
    function to_erc20(
        string memory denom
    ) external returns (address erc20_address);

    // record a cosmos message to be executed
    // after the current message execution.
    //
    // msg should be in json string format like:
    // {
    //    "@type": "/cosmos.bank.v1beta1.MsgSend",
    //    "from_address": "init13vhzmdmzsqlxkdzvygue9zjtpzedz7j87c62q4",
    //    "to_address": "init1enjh88u7c9s08fgdu28wj6umz94cetjy0hpcxf",
    //    "amount": [
    //        {
    //            "denom": "stake",
    //            "amount": "100"
    //        }
    //    ]
    // }
    //
    function execute_cosmos(string memory msg) external returns (bool dummy);

    // query a whitelisted cosmos querys.
    //
    // example)
    // path: "/slinky.oracle.v1.Query/GetPrices"
    // req: {
    //    "currency_pair_ids": ["BITCOIN/USD", "ETHEREUM/USD"]
    // }
    //
    function query_cosmos(
        string memory path,
        string memory req
    ) external returns (string memory result);
}

// lib/evm-contracts/i_erc165/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/evm-contracts/i_erc20_registry/IERC20Registry.sol

/// @dev The IERC20Registry contract's address.
address constant ERC20_REGISTRY_ADDRESS = 0x00000000000000000000000000000000000000F2;

/// @dev The IERC20Registry contract's instance.
IERC20Registry constant ERC20_REGISTRY_CONTRACT = IERC20Registry(
    ERC20_REGISTRY_ADDRESS
);

interface IERC20Registry {
    function register_erc20() external returns (bool dummy);
    function register_erc20_from_factory(
        address erc20
    ) external returns (bool dummy);
    function register_erc20_store(
        address account
    ) external returns (bool dummy);
    function is_erc20_store_registered(
        address account
    ) external view returns (bool registered);
}

// lib/evm-contracts/ownable/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;
  }
}

// lib/evm-contracts/erc165/ERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// lib/evm-contracts/erc20_acl/ERC20ACL.sol

/// @dev CHAIN_ADDRESS is the address of the chain signer.
address constant CHAIN_ADDRESS = 0x0000000000000000000000000000000000000001;

/**
 * @title ERC20ACL
 */
contract ERC20ACL {
    modifier onlyChain() {
        require(msg.sender == CHAIN_ADDRESS, "ERC20: caller is not the chain");
        _;
    }

    // check if the sender is a module address
    modifier burnable(address from) {
        require(
            !COSMOS_CONTRACT.is_module_address(from),
            "ERC20: burn from module address"
        );

        _;
    }

    // check if the recipient is a blocked address
    modifier mintable(address to) {
        require(
            !COSMOS_CONTRACT.is_blocked_address(to),
            "ERC20: mint to blocked address"
        );

        _;
    }

    // check if an recipient is blocked in bank module
    modifier transferable(address to) {
        require(
            !COSMOS_CONTRACT.is_blocked_address(to),
            "ERC20: transfer to blocked address"
        );

        _;
    }
}

// lib/evm-contracts/erc20_registry/ERC20Registry.sol

/**
 * @title ERC20Registry
 */
contract ERC20Registry {
    modifier register_erc20() {
        ERC20_REGISTRY_CONTRACT.register_erc20();

        _;
    }

    modifier register_erc20_store(address account) {
        if (!ERC20_REGISTRY_CONTRACT.is_erc20_store_registered(account)) {
            ERC20_REGISTRY_CONTRACT.register_erc20_store(account);
        }

        _;
    }
}

// lib/evm-contracts/i_erc20/IERC20.sol

interface IERC20 is IERC165 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // Custom ERC20 contracts also should have sudo transfer method
    function sudoTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external;
}

// lib/evm-contracts/initia_erc20/InitiaERC20.sol

contract InitiaERC20 is IERC20, Ownable, ERC20Registry, ERC165, ERC20ACL {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC165) returns (bool) {
        return
            interfaceId == type(IERC20).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) register_erc20 {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal register_erc20_store(recipient) {
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal register_erc20_store(to) {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external transferable(recipient) returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external transferable(recipient) returns (bool) {
        allowance[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function mint(address to, uint256 amount) external mintable(to) onlyOwner {
        _mint(to, amount);
    }

    function burn(
        address from,
        uint256 amount
    ) external burnable(from) onlyOwner {
        _burn(from, amount);
    }

    function sudoTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external onlyChain {
        _transfer(sender, recipient, amount);
    }
}

