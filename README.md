# RWA-conduits

    Conduit will enable deposits to yield bearing strategy. 
    Home Loan Strategy is one of them which allows RWA review and loan to be granted by the conduit . 
    So the test has
        depositing to the conduit, 
        DAO allows and creates a new loan for some amount. 
        There’s a predefined interest rate and when they make payments for loan, it’ll calculate new principal. 
        When someone withdraws from the conduit, the 2% interest rate is calculated and given back.
        Main test is `test_new_loan_with_full_payment_and_withdrawal`



Please run as 

`forge test`


install dependencies via forge install


Tests: https://github.com/antojoseph/ConduitRWA/blob/main/test/arranger-conduit/HomeLoanProtocol.t.sol

Home Loan protocol: https://github.com/antojoseph/ConduitRWA/blob/main/src/HomeLoanProtocol.sol

Home Loan stratergy: https://github.com/antojoseph/ConduitRWA/blob/main/src/HomeLoanStrategy.sol

Integrating with contracts: https://github.com/antojoseph/ConduitRWA/blob/fa6abe55fffe24575dc8abadc9cb453110746b1e/test/arranger-conduit/HomeLoanProtocol.t.sol#L29