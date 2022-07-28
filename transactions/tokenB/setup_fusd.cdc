// setup_tokenB.cdc

import FungibleToken    from 0xee82856bf20e2aa6
import TokenB from 0x082fb01090d0eed5

transaction(amount: UFix64, recipient: Address)
{
    let admin       : &TokenB.Administrator
    let signer      : AuthAccount
    let receiverRef : &{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.admin  = signer.borrow<&TokenB.Administrator>(from: TokenB.AdminStoragePath)!
        self.receiverRef = getAccount(recipient)
            .getCapability<&{FungibleToken.Receiver}>(/public/tokenBReceiver)!
            .borrow()!
    }

    execute {
        let minter <- self.admin.createNewMinter()
        let vault <- minter.mintTokens(amount: amount)
        self.signer.save(<-minter, to: TokenB.MinterProxyStoragePath)
        self.signer.link<&TokenB.Minter>(TokenB.MinterProxyPublicPath, target: TokenB.MinterProxyStoragePath)
        self.receiverRef.deposit(from: <-vault)
    }
}