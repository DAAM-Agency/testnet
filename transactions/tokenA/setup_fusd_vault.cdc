// This transaction configures the signer's account with an empty TokenA vault.
//
// It also links the following capabilities:
//
// - FungibleToken.Receiver: this capability allows this account to accept TokenA deposits.
// - FungibleToken.Balance: this capability allows anybody to inspect the TokenA balance of this account.

import FungibleToken from 0x9a0766d93b6608b7
import TokenA from 0xec4809cd812aee0a

transaction {

    prepare(signer: AuthAccount) {

        // It's OK if the account already has a Vault, but we don't want to replace it
        if(signer.borrow<&TokenA.Vault>(from: /storage/tokenAVault) != nil) {
            log("Already have a wallet.")
            return
        }
        
        // Create a new TokenA Vault and put it in storage
        signer.save(<-TokenA.createEmptyVault(), to: /storage/tokenAVault)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&TokenA.Vault{FungibleToken.Receiver}>(
            /public/tokenAReceiver,
            target: /storage/tokenAVault
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&TokenA.Vault{FungibleToken.Balance}>(
            /public/tokenABalance,
            target: /storage/tokenAVault
        )
    }
}
