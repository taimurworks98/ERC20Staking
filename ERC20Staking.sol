// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

/// @author Taimoor Malik

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mintERC20Token(address to, uint256 amount) external;
}

interface ICircularityPair is IERC20 {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface ICircularityRouter01 {
    function factory() external view returns (address);

    function WXDC() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityXDC(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountXDCMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountXDC, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityXDC(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountXDCMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountXDC);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityXDCWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountXDCMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountXDC);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactXDCForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactXDC(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForXDC(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapXDCForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

contract ERC20Stake is Ownable, ReentrancyGuard {
    uint256 public apyPercentage;
    address public lpAddress;
    address public rewardTokenAddress;
    uint256 public price;

    struct Stake {
        uint256 startTime;
        bool withdrawn;
    }

    struct TotalStake {
        uint256 totalStake;
        uint256 startTime;
        uint256 reward;
    }

    mapping(address => mapping(uint256 => Stake)) public stakes;

    mapping(address => TotalStake) public totalStake;

    event Staked(address indexed staker, uint256 startTime);
    event Flushed(address indexed owner, uint256 time, uint256 amount);
    event Claimed(address indexed staker, uint256 amount, uint256 reward);
    event Withdrawn(address indexed staker, uint256 amount, uint256 reward);
    event ApyUpdated(address indexed owner, uint256 time, uint256 percentage);

    constructor(
        address _lpAddress,
        address _rewardTokenAddress,
        uint256 _apyPercentage,
        uint256 _price
    ) {
        lpAddress = _lpAddress;
        rewardTokenAddress = _rewardTokenAddress;
        apyPercentage = _apyPercentage;
        price = _price;
    }

    /// @notice This is an external stake function, this function stakes an nft to claim rewards later
    /// @param _tokenAmount This parameter indicates address which requires to burn tokens
    function stake(uint256 _tokenAmount) external {
        require(
            ICircularityPair(lpAddress).balanceOf(msg.sender) > 0,
            "You need to own at least one LP Token"
        );
        require(_tokenAmount > 0, "Stake amount must be greater then 0");

        ICircularityPair(lpAddress).transferFrom(
            msg.sender,
            address(this),
            _tokenAmount
        );

        // Calculate and save the rewards for the previous staking period
        uint256 pendingReward = totalStake[msg.sender].reward;
        uint256 reward = calculateReward(msg.sender);
        reward = reward + pendingReward;

        if (reward > 0) {
            saveReward(msg.sender, reward);
        }

        // Update the start time for subsequent claims
        totalStake[msg.sender].startTime = block.timestamp;
        stakes[msg.sender][_tokenAmount].startTime = block.timestamp;
        // Add the new LP tokens to the stake
        totalStake[msg.sender].totalStake += _tokenAmount;

        emit Staked(msg.sender, block.timestamp);
    }

    /// @notice This is an external withdraw function, this function withdraws specific tokenid of a user with applicable claim rewards
    /// @param _tokenAmount This parameter indicates address which requires to burn tokens
    function withdraw(uint256 _tokenAmount) external nonReentrant {
        require(_tokenAmount > 0, "Withdraw amount must be greater then 0");
        uint256 totalStaked = totalStake[msg.sender].totalStake;
        uint256 pendingReward = totalStake[msg.sender].reward;

        require(totalStaked > 0, "You have no stake");

        uint256 reward = calculateReward(msg.sender);
        reward = reward + pendingReward;

        if (IERC20(rewardTokenAddress).balanceOf(address(this)) > reward) {
            IERC20(rewardTokenAddress).transfer(msg.sender, reward);
        }

        ICircularityPair(lpAddress).transfer(msg.sender, _tokenAmount);

        stakes[msg.sender][_tokenAmount].withdrawn = true;
        totalStake[msg.sender].totalStake = totalStaked - _tokenAmount;
        totalStake[msg.sender].reward = 0;
        totalStake[msg.sender].startTime = block.timestamp;

        emit Withdrawn(msg.sender, totalStaked, reward);
        emit Claimed(msg.sender, totalStaked, reward);
    }

    /// @notice This is a public claimReward function, this function allows stakers to claim their staking reward
    function claimReward() public nonReentrant {
        uint256 totalStaked = totalStake[msg.sender].totalStake;
        require(totalStaked > 0, "You have no stake");

        uint256 pendingReward = totalStake[msg.sender].reward;

        uint256 reward = calculateReward(msg.sender);
        reward = reward + pendingReward;

        require(reward > 0, "No reward to claim");
        require(
            IERC20(rewardTokenAddress).balanceOf(address(this)) > reward,
            "Insufficient reward balance"
        );

        // Transfer the reward tokens to the sender
        IERC20(rewardTokenAddress).transfer(msg.sender, reward);

        // Update the start time for subsequent claims
        totalStake[msg.sender].startTime = block.timestamp;
        totalStake[msg.sender].reward = 0;

        emit Claimed(msg.sender, totalStake[msg.sender].totalStake, reward);
    }

    /// @notice This is a public calculateReward function, this function calculate reward based on users stake amount and pair price subject to apy
    /// @param _staker This parameter indicates address of staker
    function calculateReward(address _staker) public view returns (uint256) {
        require(_staker != address(0), "Cannot query rewards for zero address");
        uint256 rate = price;
        uint256 totalStaked = totalStake[_staker].totalStake;
        uint256 startTime = totalStake[_staker].startTime;
        uint256 per = (rate / 100) * apyPercentage;
        uint256 reward = ((block.timestamp - startTime) *
            (totalStaked / 1 ether) *
            per) / (365 days);
        return reward;
    }

    /// @notice This is an internal saveReward function, this function saves pending rewards before additional LP-Tokens are staked
    /// @param _staker This parameter indicates address of staker
    /// @param _reward This parameter indicates reward amount of staker
    function saveReward(address _staker, uint256 _reward) internal {
        totalStake[_staker].reward = _reward;
    }

    /// @notice This is an external setAPY function, this function sets annual percentage yield value of staking
    /// @param _apyPercentage This parameter indicates amount of apy to be set
    function setAPY(uint256 _apyPercentage) external onlyOwner {
        require(_apyPercentage > 0, "APY percentage must be greater then 0");
        apyPercentage = _apyPercentage;
        emit ApyUpdated(msg.sender, block.timestamp, _apyPercentage);
    }

    /// @notice This is an flushContract setAPY function, this function flush all contract tokens to specified address
    /// @param _account This parameter indicates address which will receive all tokens
    function flushContract(address _account) external onlyOwner {
        require(
            _account != address(0),
            "Cannot transfer contract balance to zero address"
        );
        uint256 balance = IERC20(rewardTokenAddress).balanceOf(address(this));
        IERC20(rewardTokenAddress).transfer(_account, balance);
        emit Flushed(msg.sender, block.timestamp, balance);
    }
}
