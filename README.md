Assignment-1: Token Sale
---------------------------------------
1. Writing a createToken contract to create token. Whenever someone contribute, minting function of this contract is called.
2. min-contribution is set to be 10 ether, for both presale and public-sale.
3. funtion presale/public-sale can be called by owner only. Both are boolean values which are used to activate/deactivate sessions.
4. require conditions for contribution are checked and events of contributions are logged in.
5. Constructor value: // "broToken","BRO",5e18,5e18,1e18,3e18,1e18,3e18,0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 -testcase
6. security measures- protected from Reentrency in claimRefund() function.
----------------------------------------

Assignment-2: Decentralised-Voting System
----------------------------------------
1. Cnadidate details has been stored in structure.
2. Voters can register they will added to registeredVoters variable.
3. voting can be started and ended by owner- going to change logic for that by making use of time-period thus making it truely decentralised.
4. Id of candidate is used for voting. (Range of candidate id is 1 to number of candidates)
5. people can check candidates count( getCountCandidates - function) that retrieve info of all candidate(getCandidates - function)
6. after going through candidates,they can vote by putting Id of that Candidate in vote() function.
7. winner() function can be called after voting has been ended by anyone, if same number of votes are there then it returns "Draw".
----------------------------------------

Assinment-3: Token Sawap (Test-File included)
---------------------------------------------
1. mint contract to mint 2 different types of Token
2. using Swap function to safely swap tokens from both accounts.
3. 100 tokenA = 300 tokenB
4. rest details are mentioned in testing file(as comments) of how the tokens are being swapped, after swapping balanced of each owner is tested, both test case passed
-----------------------------------------------

Assignment-4: Multi-Signature Wallet
-------------------------------------------
1. array of owner is passes initially, dublicate owner are checked using a map.
2. Anyone can submit() a transaction; owners will approve() or revokeConfirmation().
3. after the countApproval() is greater than required number of apporval, any owner can execute the transaction.
4. required number is passed initially.
5. requried function are used to stop any potential attack while considering all edge cases.
--------------------------------------------

All contracts are tested by running locally, for normal casses, working without any error
