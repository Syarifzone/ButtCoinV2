 pragma solidity 0.5 .11;

 // 'ButtCoin' contract, version 2.0
 // Website: http://www.0xbutt.com/
 //
 // Symbol      : ButtCoin
 // Name        : 0xBUTT 
 // Total supply: 33,554,467.00
 // Decimals    : 8
 //
 // ----------------------------------------------------------------------------

  

 // ----------------------------------------------------------------------------
 // ERC Token Standard #20 Interface
 // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 // ----------------------------------------------------------------------------

 contract ERC20Interface {

   function totalSupply() public view returns(uint);

   function balanceOf(address tokenOwner) public view returns(uint balance);

   function allowance(address tokenOwner, address spender) public view returns(uint remaining);

   function transfer(address to, uint tokens) public returns(bool success);

   function approve(address spender, uint tokens) public returns(bool success);

   function transferFrom(address from, address to, uint tokens) public returns(bool success);

   function rootTransfer(address from, address to, uint tokens) public returns(bool success);

   function addToRootAccounts(address addRootAccount) public;

   function removeFromRootAccounts(address removeRootAccount) public;

   function addToWhitelist(address toWhitelist) public;

   function removeFromBlacklist(address toBlacklist) public;

   function removeFromWhitelist(address toWhitelist) public;

   function switchTransferLock() public;

   function switchTransferFromLock() public;

   function switchRootTransferLock() public;

   function switchMintLock() public;

   function switchApproveLock() public;

   function switchApproveAndCallLock() public;

   function confirmBlacklist(address tokenAddress) public returns(bool);

   function confirmWhitelist(address tokenAddress) public returns(bool);

   function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success);

   function setDifficulty(uint difficulty) public returns(bool success);

   function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool success);

   function getChallengeNumber() public view returns(bytes32);

   function getMiningDifficulty() public view returns(uint);

   function getMiningTarget() public view returns(uint);

   function getMiningReward() public view returns(uint);

   function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns(bytes32);

   function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns(bool success);

 
   event Transfer(address indexed from, address indexed to, uint tokens);
   event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 }

 // ----------------------------------------------------------------------------
 // Contract function to receive approval and execute function in one call
 //
 // Borrowed from MiniMeToken
 // ----------------------------------------------------------------------------

 contract ApproveAndCallFallBack {
   function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
 }

 // ----------------------------------------------------------------------------
 // Owned contract
 // ----------------------------------------------------------------------------

 contract Owned {

   address public owner;
   address public newOwner;

   event OwnershipTransferred(address indexed _from, address indexed _to);

   constructor() public {
     owner = msg.sender;
   }

   modifier onlyOwner {
     require(msg.sender == owner);
     _;
   }

   function transferOwnership(address _newOwner) public onlyOwner {
     newOwner = _newOwner;
   }

   function acceptOwnership() public {
     require(msg.sender == newOwner);
     emit OwnershipTransferred(owner, newOwner);
     owner = newOwner;
     newOwner = address(0);
   }

 }

 // ----------------------------------------------------------------------------
 // Locks contract
 // All booleans are with a false as a default. 
 // The main public functions of a great importance are to be secured with a lock.
 // ----------------------------------------------------------------------------
 contract Locks is Owned {

   mapping(address => bool) internal blacklist; //in case there are accounts that need to be blocked, good for preventing attacks (can be useful in ransomware attacks).
   mapping(address => bool) internal whitelist; //for whitelisting the accounts such as exchanges, etc.
   mapping(address => bool) internal rootAccounts; //for whitelisting the accounts such as exchanges, etc.

   //false means unlocked, answering the question, "is it locked ?"
   bool internal constructorLock = false; //makes sure that constructor of the main is executed only once.
   bool public transferLock = false; //we can lock the transfer function in case there is an emergency situation.
   bool public transferFromLock = false; //we can lock the transferFrom function in case there is an emergency situation.
   bool public rootTransferLock = false; //we can lock the rootTransfer fucntion in case there is an emergency situation.
   bool public mintLock = false; //we can lock the mint function, for emergency only.
   bool public approveLock = false; //we can lock the approve function.
   bool public approveAndCallLock = false; //we can lock the approve and call function

   function addToRootAccounts(address addRootAccount) public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     rootAccounts[addRootAccount] = true;
   }

   function removeFromRootAccounts(address removeRootAccount) public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     rootAccounts[removeRootAccount] = false;
   }

   function addToWhitelist(address toWhitelist) public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     whitelist[toWhitelist] = true;
   }

   function removeFromBlacklist(address toBlacklist) public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     blacklist[toBlacklist] = false;
   }

   function removeFromWhitelist(address toWhitelist) public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     blacklist[toWhitelist] = false;
   }

   //constructor's lock cannot be switched

   function switchTransferLock() public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     transferLock = !transferLock;
   }

   function switchTransferFromLock() public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     transferFromLock = !transferFromLock;
   }

   function switchRootTransferLock() public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     rootTransferLock = !rootTransferLock;
   }

   function switchMintLock() public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     mintLock = !mintLock;
   }

   function switchApproveLock() public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     approveLock = !approveLock;
   }

   function switchApproveAndCallLock() public {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     approveAndCallLock = !approveAndCallLock;
   }


   // ------------------------------------------------------------------------
   // Tells whether the address is blacklisted. True if yes, False if no.  
   // ------------------------------------------------------------------------
   function confirmBlacklist(address tokenAddress) public returns(bool) {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     return blacklist[tokenAddress];
   }

   // ------------------------------------------------------------------------
   // Tells whether the address is whitelisted. True if yes, False if no.  
   // ------------------------------------------------------------------------
   function confirmWhitelist(address tokenAddress) public returns(bool) {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     return whitelist[tokenAddress];
   }

   // ------------------------------------------------------------------------
   // Tells whether the address is a root. True if yes, False if no.  
   // ------------------------------------------------------------------------
   function confirmRoot(address tokenAddress) public returns(bool) {
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Only the contract owner OR root accounts can initiate it");
     return rootAccounts[tokenAddress];
   }

 }

 // ----------------------------------------------------------------------------
 // Stats contract
 // Keeping the stats about the main
 // ----------------------------------------------------------------------------
 contract Stats {
   uint public tokensMined;
   uint public tokensBurned;
   uint public tokensGenerated;
   address public lastRewardTo;
   address public lastTransferTo = address(0);
   uint public totalGasSpent;
   uint public lastRewardAmount;
   uint public latestDifficultyPeriodStarted;
   uint public blockCount; //number of 'blocks' mined
   bytes32 public challengeNumber; //generate a new one when a new reward is minted
   uint public rewardEra;
   uint public miningTarget;
   uint public lastRewardEthBlockNumber;
   uint public lastMiningOccured;
 }

 // ----------------------------------------------------------------------------
 // Constants contract
 // Keeping the constant variables about the main
 // ----------------------------------------------------------------------------
 contract Constants {
   string public symbol;
   string public name;
   uint8 public decimals;
   uint public _MAXIMUM_TARGET = 2 ** 223; //a big number, smaller the number, greater the difficulty, assume this is 1% of burning
   uint public _BLOCKS_PER_ERA = 210000; 
 }

 // ----------------------------------------------------------------------------
 // Constants contract
 // Keeping the constant variables about the main
 // ----------------------------------------------------------------------------
 contract Maps {
   mapping(bytes32 => bytes32) solutionForChallenge;
   mapping(address => uint) balances;
   mapping(address => mapping(address => uint)) allowed;
   mapping(address => uint) minedBlocks;
 }

 // ----------------------------------------------------------------------------
 // ERC20 Token, with the addition of symbol, name and decimals and an
 // initial fixed supply
 // ----------------------------------------------------------------------------

 contract Zero_x_butt_v2 is ERC20Interface, Locks, Stats, Constants, Maps {

  
   event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

   // ------------------------------------------------------------------------
   // Constructor
   // ------------------------------------------------------------------------

   constructor() public onlyOwner {
     if (constructorLock) revert();
     constructorLock = true;

        symbol = "0xBUTT";
        name = "ButtCoin";
        decimals = 8;
        
        tokensMined = 0;
        tokensBurned = 0;
        tokensGenerated = 33554467 * 10 ** uint(decimals);
        lastRewardTo = address(0);
        lastTransferTo = address(0);
        totalGasSpent = 0;
        lastRewardAmount = 0;
        latestDifficultyPeriodStarted = block.number;
        blockCount = 0;
        challengeNumber = 0;
        rewardEra = 0;
        lastMiningOccured = now;
        
        emit Transfer(address(0), owner, tokensGenerated);
        balances[owner] = tokensGenerated;  
        _startNewMiningEpoch();     
     
        totalGasSpent += tx.gasprice;
   }

   function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success) {
     require(!blacklist[msg.sender], "Blacklisted accounts cannot mint");
     require(!mintLock, "The function must be unlocked");

     uint reward_amount = getMiningReward();
     if (reward_amount == 0) revert(); //we do not want to charge for a no-reward.

     //the PoW must contain work that includes a recent ethereum block hash (challenge number) and the msg.sender's address to prevent MITM attacks
     bytes32 digest = keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce));
     //the challenge digest must match the expected
     if (digest != challenge_digest) revert();
     //the digest must be smaller than the target
     if (uint256(digest) > miningTarget) revert();
     //only allow one reward for each challenge
     bytes32 solution = solutionForChallenge[challengeNumber];
     solutionForChallenge[challengeNumber] = digest;
     if (solution != 0x0) revert(); //prevent the same answer from awarding twice
     balances[msg.sender] += reward_amount;
     tokensMined += reward_amount;
     //Cannot mint more tokens than there are
     //set readonly diagnostics data
     lastRewardTo = msg.sender;
     lastRewardAmount = reward_amount;
     lastRewardEthBlockNumber = block.number;
     _startNewMiningEpoch();
     emit Mint(msg.sender, reward_amount, blockCount, challengeNumber);
     minedBlocks[msg.sender] = reward_amount;
     lastMiningOccured = now;

     totalGasSpent += tx.gasprice;
     return true;
   }

   //a new 'block' to be mined
   function _startNewMiningEpoch() internal {
     require(!blacklist[msg.sender]); //must not be blacklisted

     //There is no max supply and rewards depend on burning only
     //set the next minted supply at which the era will change
     blockCount += 1;

     if ((blockCount % _BLOCKS_PER_ERA == 0)) {
       rewardEra = rewardEra + 1;
     }

     //we are readjusting the difficulty each time the block is mined
     _reAdjustDifficulty();

     //make the latest ethereum block hash a part of the next challenge for PoW to prevent pre-mining future blocks
     //do this last since this is a protection mechanism in the mint() function
     challengeNumber = blockhash(block.number - 1);
   }

   function _reAdjustDifficulty() internal {
     require(!blacklist[msg.sender]); //must not be blacklisted

     uint reward = getMiningReward();
     uint difficultyExponent = toDifficultyExponent(reward);
     miningTarget = (2 ** difficultyExponent); //estimated

     latestDifficultyPeriodStarted = block.number;

     if (miningTarget > _MAXIMUM_TARGET) //very easy
     {
       miningTarget = _MAXIMUM_TARGET;
     }
   }

   //Find the exponent to convert tokens to a difficulty
   function toDifficultyExponent(uint tokens) internal returns(uint) {
     for (uint t = 0; t < 232; t++) {
       if ((t ** 3) * (10 ** uint(decimals)) >= tokens) return 232 - t;
     }
     return 0;
   }

   //If we ever need to design a different difficulty algorithm, we don't need another token, we can continue with this one using a different mining contract
   function setDifficulty(uint difficulty) public returns(bool success) {
     require(!blacklist[msg.sender]); //must not be blacklisted
     require(address(msg.sender) == address(owner) || rootAccounts[msg.sender], "Must be an owner or a root account");
     miningTarget = difficulty;
     totalGasSpent += tx.gasprice;
     return true;
   }

 

   // ------------------------------------------------------------------------
   // Transfer the balance from token owner's account to `to` account
   // Transfer function is a core to a token and not to be overriden
   // - Owner's account must have sufficient balance to transfer
   // - 0 value transfers are allowed
   // ------------------------------------------------------------------------
   function transfer(address to, uint tokens) public returns(bool success) {
     require(tokens <= balances[msg.sender], "Amount of tokens exceeded the maximum");
     require(transferLock || !whitelist[msg.sender], "The function must be unlocked OR the account whitelisted");
     if (blacklist[msg.sender]) {
       //we do not process the transfer for the blacklisted accounts, instead we burn their tokens.
       balances[msg.sender] -= tokens;
       balances[address(0)] += tokens;
       emit Transfer(msg.sender, address(0), tokens);
       tokensBurned = tokensBurned + tokens;
     } else {
       uint toBurn = tokens/100; //this is a 1% of the tokens amount
       uint toPrevious = toBurn; //we send 1% to a previous account as well
       uint toSend = tokens-(toBurn+toPrevious);

       balances[msg.sender] -= tokens;

       balances[to] += toSend;
       emit Transfer(msg.sender, to, toSend);

       balances[lastTransferTo] += toPrevious;
       if (address(msg.sender) != address(lastTransferTo)) { //there is no need to send the 1% to yourself
         emit Transfer(msg.sender, lastTransferTo, toPrevious);
       }

       balances[address(0)] += toBurn;
       emit Transfer(msg.sender, address(0), toBurn);
       tokensBurned = tokensBurned + toBurn;

       lastTransferTo = to;
     }
     _reAdjustDifficulty(); //since we are burning and sometimes rarely mining, we need this call

     totalGasSpent += tx.gasprice;
     return true;
   }

   // ------------------------------------------------------------------------
   // Transfer the balance from token owner's account to `to` account without burning
   // Can be used for burning purposes too.
   // Can be used for minting purposes in case of an emergency.
   // - Owner's account must have sufficient balance to transfer
   // - 0 value transfers are allowed
   // ------------------------------------------------------------------------
   function rootTransfer(address from, address to, uint tokens) public returns(bool success) {
     require(!rootTransferLock && (address(msg.sender) == address(owner) || rootAccounts[msg.sender]), "Function locked OR not an owner/root ");
     require(address(from) != address(to), "From address cannot be same as a To address");

     balances[msg.sender] -= tokens;
     balances[to] += tokens;
     emit Transfer(from, to, tokens);

     if (address(from) == address(0)) {
       tokensGenerated = tokensGenerated + tokens;
     }

     if (address(to) == address(0)) {
       tokensBurned = tokensBurned + tokens;
     }

     totalGasSpent += tx.gasprice;
     return true;
   }

   // ------------------------------------------------------------------------
   // Token owner can approve for `spender` to transferFrom(...) `tokens`
   // from the token owner's account
   //
   // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
   // recommends that there are no checks for the approval double-spend attack
   // as this should be implemented in user interfaces
   // ------------------------------------------------------------------------
   function approve(address spender, uint tokens) public returns(bool success) {
     require(spender != address(0), "Cannot approve for address(0)");
     require(!approveLock, "Must be unlocked");
     require(!blacklist[msg.sender], "Cannot be a Blacklisted account");

     allowed[msg.sender][spender] = tokens;
     emit Approval(msg.sender, spender, tokens);

     totalGasSpent += tx.gasprice;
     return true;
   }

   // ------------------------------------------------------------------------
   // Transfer `tokens` from the `from` account to the `to` account
   // Transfer function is a core to a token and not to be overriden
   // The calling account must already have sufficient tokens approve(...)-d
   // for spending from the `from` account and
   // - From account must have sufficient balance to transfer
   // - Spender must have sufficient allowance to transfer
   // - 0 value transfers are allowed
   // ------------------------------------------------------------------------
   function transferFrom(address from, address to, uint tokens) public returns(bool success) {

     require(tokens <= balances[from], "Amount exceeded the maximum");
     require(tokens <= allowed[from][msg.sender], "Amount exceeded the maximum");
     require(!transferFromLock && whitelist[msg.sender], "Must be unlocked AND whitelisted");
     require(address(from) != address(0), "Cannot send from address(0)"); //you cannot mint by sending, it has to be done by mining.
     require(!blacklist[msg.sender], "Cannot be a Blacklisted account");

     uint toBurn = tokens/100; //this is a 1% of the tokens amount
     uint toPrevious = toBurn;
     uint toSend = tokens-(toBurn+toPrevious);

     balances[from] -= tokens;
     allowed[from][msg.sender] -= tokens;

     balances[to] += toSend;
     balances[lastTransferTo] += toBurn;
     balances[address(0)] += toBurn;

     emit Transfer(from, to, toSend);
     if (address(from) != address(lastTransferTo)) { //there is no need to send the 1% to yourself
       emit Transfer(from, lastTransferTo, toPrevious);
     }

     emit Transfer(from, address(0), toBurn);
     tokensBurned = tokensBurned + toBurn;

     lastTransferTo = to;
     _reAdjustDifficulty(); //since we are burning and sometimes rarely mining, we need this call

     totalGasSpent += tx.gasprice;
     return true;

   }

   // ------------------------------------------------------------------------
   // Token owner can approve for `spender` to transferFrom(...) `tokens`
   // from the token owner's account. The `spender` contract function
   // `receiveApproval(...)` is then executed
   // ------------------------------------------------------------------------
   function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool success) {
     require(!approveAndCallLock && whitelist[msg.sender], "Must be unlocked AND whitelisted");
     require(!blacklist[msg.sender], "Cannot be a Blacklisted account");

     allowed[msg.sender][spender] = tokens;
     emit Approval(msg.sender, spender, tokens);
     ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
     totalGasSpent += tx.gasprice;
     return true;
   }

   // ------------------------------------------------------------------------
   // Don't accept ETH
   // ------------------------------------------------------------------------

   function () external payable {
     revert();
   }

   // ------------------------------------------------------------------------
   // Owner can transfer out any accidentally sent ERC20 tokens
   // ------------------------------------------------------------------------

   function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns(bool success) {
     return ERC20Interface(tokenAddress).transfer(owner, tokens);
   }

 
   // ------------------------------------------------------------------------
   // Returns the amount of tokens approved by the owner that can be
   // transferred to the spender's account
   // ------------------------------------------------------------------------
   function allowance(address tokenOwner, address spender) public view returns(uint remaining) {
     return allowed[tokenOwner][spender];
   }

   // ------------------------------------------------------------------------
   // Total supply
   // ------------------------------------------------------------------------
   function totalSupply() public view returns(uint) {
     return (tokensGenerated + tokensMined) - tokensBurned;
   }

   // ------------------------------------------------------------------------
   // Get the token balance for account `tokenOwner`
   // ------------------------------------------------------------------------
   function balanceOf(address tokenOwner) public view returns(uint balance) {
     return balances[tokenOwner];
   }

   //this is a recent ethereum block hash, used to prevent pre-mining future blocks
   function getChallengeNumber() public view returns(bytes32) {
     return challengeNumber;
   }

   //the number of zeroes the digest of the PoW solution requires.  Auto adjusts
   function getMiningDifficulty() public view returns(uint) {
     return _MAXIMUM_TARGET/miningTarget;
   }

   function getMiningTarget() public view returns(uint) {
     return miningTarget;
   }

   function getMiningReward() public view returns(uint) {
     return tokensBurned/50; //this is two percent of burned tokens
   }

   //help debug mining software
   function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns(bytes32 digesttest) {
     bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
     return digest;
   }

   //help debug mining software
   function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns(bool success) {
     bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
     if (uint256(digest) > testTarget) revert();
     return (digest == challenge_digest);
   }
 }
