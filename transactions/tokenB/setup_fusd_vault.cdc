// This transaction configures the signer's account with an empty TokenB vault.
//
// It also links the following capabilities:
//
// - FungibleToken.Receiver: this capability allows this account to accept TokenB deposits.
// - FungibleToken.Balance: this capability allows anybody to inspect the TokenB balance of this account.

import FungibleToken from 0xee82856bf20e2aa6
import TokenB from 0x082fb01090d0eed5

transaction {

    prepare(signer: AuthAccount) {

        // It's OK if the account already has a Vault, but we don't want to replace it
        if(signer.borrow<&TokenB.Vault>(from: /storage/tokenBVault) != nil) {
            return
        }
        
        // Create a new TokenB Vault and put it in storage
        signer.save(<-TokenB.createEmptyVault(), to: /storage/tokenBVault)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&TokenB.Vault{FungibleToken.Receiver}>(
            /public/tokenBReceiver,
            target: /storage/tokenBVault
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&TokenB.Vault{FungibleToken.Balance}>(
            /public/tokenBBalance,
            target: /storage/tokenBVault
        )
    }
}
