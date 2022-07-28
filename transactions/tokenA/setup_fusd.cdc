// setup_tokenA.cdc

import FungibleToken    from 0xee82856bf20e2aa6
import TokenA from 0xec4809cd812aee0a

transaction(amount: UFix64, recipient: Address)
{
    let admin       : &TokenA.Administrator
    let signer      : AuthAccount
    let receiverRef : &{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.admin  = signer.borrow<&TokenA.Administrator>(from: TokenA.AdminStoragePath)!
        self.receiverRef = getAccount(recipient)
            .getCapability<&{FungibleToken.Receiver}>(/public/tokenAReceiver)!
            .borrow()!
    }

    execute {
        let minter <- self.admin.createNewMinter()
        let vault <- minter.mintTokens(amount: amount)
        self.signer.save(<-minter, to: TokenA.MinterProxyStoragePath)
        self.signer.link<&TokenA.Minter>(TokenA.MinterProxyPublicPath, target: TokenA.MinterProxyStoragePath)
        self.receiverRef.deposit(from: <-vault)
    }
}