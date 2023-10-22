# RWA-conduits

3 files, HomeLoanProtocol, HomeLoanStrategy, and the HomeLoanProtocol.t.sol test. Essentially conduit will enable deposit to yield bearing strategy. Home Loan Strategy is one of them which is essentially allowing RWA review and loan to be granted by the conduit . So the test has, depositing to the conduit, DAO allows and creates a new loan for some amount. There’s a predefined interest rate and when they make payments for loan, it’ll calculate new principal. When someone withdraws from the conduit, the 2% interest rate is calculated and given back. Main test is this test_new_loan_with_full_payment_and_withdrawal



Please run as 

forge test -vvvv --match-path test/arranger-conduit/HomeLoanProtocol.t.sol  --fork-url RPC_URL


install dependencies via forge install


Tests here : https://github.com/antojoseph/ConduitRWA/test/arranger-conduit/HomeLoanProtocol.t.sol 

Home Loan protocol here : https://github.com/antojoseph/ConduitRWA/blob/main/src/HomeLoanProtocol.sol

Home Loan stratergy protocol here : https://github.com/antojoseph/ConduitRWA/blob/main/src/HomeLoanStrategy.sol

Integrating with contract here : https://github.com/antojoseph/ConduitRWA/blob/fa6abe55fffe24575dc8abadc9cb453110746b1e/test/arranger-conduit/HomeLoanProtocol.t.sol#L29