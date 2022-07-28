// This transaction withdraws TokenB from the signer's account and deposits it into a recipient account. 
// This transaction will fail if the recipient does not have an TokenB receiver. 
// No funds are transferred or lost if the transaction fails.
//
// Parameters:
// - amount: The amount of TokenB to transfer (e.g. 10.0)
// - to: The recipient account address.
//
// This transaction will fail if either the sender or recipient does not have
// an TokenB vault stored in their account. To check if an account has a vault
// or initialize a new vault, use check_tokenB_vault_setup.cdc and setup_tokenB_vault.cdc
// respectively.

import FungibleToken from 0xee82856bf20e2aa6
import TokenB from 0x082fb01090d0eed5

transaction(amount: UFix64, to: Address) {

    // The Vault resource that holds the tokens that are being transferred
    let sentVault: @FungibleToken.Vault

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's stored vault
        let vaultRef = signer.borrow<&TokenB.Vault>(from: /storage/tokenBVault)
            ?? panic("Could not borrow reference to the owner's Vault!")

        // Withdraw tokens from the signer's stored vault
        self.sentVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        // Get the recipient's public account object
        let recipient = getAccount(to)

        // Get a reference to the recipient's Receiver
        let receiverRef = recipient.getCapability(/public/tokenBReceiver)!.borrow<&{FungibleToken.Receiver}>()
            ?? panic("Could not borrow receiver reference to the recipient's Vault")

        // Deposit the withdrawn tokens in the recipient's receiver
        receiverRef.deposit(from: <-self.sentVault)
    }
}
