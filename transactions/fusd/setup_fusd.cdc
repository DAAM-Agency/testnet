// setup_fusd.cdc

import FungibleToken    from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68

transaction(amount: UFix64, recipient: Address)
{
    let admin       : &FUSD.Administrator
    let signer      : AuthAccount
    let receiverRef : &{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.admin  = signer.borrow<&FUSD.Administrator>(from: FUSD.AdminStoragePath)!
        self.receiverRef = getAccount(recipient)
            .getCapability<&{FungibleToken.Receiver}>(/public/fusdReceiver)!
            .borrow()!
    }

    execute {
        let minter <- self.admin.createNewMinter()
        let vault <- minter.mintTokens(amount: amount)
        self.signer.save(<-minter, to: FUSD.MinterProxyStoragePath)
        self.signer.link<&FUSD.Minter>(FUSD.MinterProxyPublicPath, target: FUSD.MinterProxyStoragePath)
        self.receiverRef.deposit(from: <-vault)
    }
}