import FungibleToken from 0xee82856bf20e2aa6
import MetadataViews from 0xf8d6e0586b0a20c7

pub contract MultiToken
{
    pub let MultiTokenPublicPath  : PublicPath
    pub let MultiTokenStoragePath : StoragePath

    pub resource MultiTokenManager: FungibleToken.Receiver
    {
        pub fun deposit(from: @FungibleToken.Vault) // deposit takes a Vault and deposits it into the implementing resource type
        { 
            let type = from.getType()
            let identifier = type.identifier
            var path: PublicPath? = nil


            switch identifier {
                case "A.192440c99cb17282.FUSD.Vault": path = /public/fusdReceiver
            }
            
            //let ref = getAccount(self.owner!.address).getCapability(/public/fusdReceiver)!.borrow<&{FungibleToken.Receiver}>()!
            let ref = self.owner!.getCapability(path!)!.borrow<&{FungibleToken.Receiver}>() ??  // Get a reference to the recipient's Receiver
                panic("Create a Wallet from: ".concat(identifier))
            ref.deposit(from: <-from)    // Deposit the withdrawn tokens in the recipient's receiver
        }
    }

    init() {
        self.MultiTokenPublicPath  = MetadataViews.getRoyaltyReceiverPublicPath()
        self.MultiTokenStoragePath = /storage/MultiTokenManager
    }
}