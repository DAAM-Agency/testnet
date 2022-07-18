import FungibleToken from 0xee82856bf20e2aa6
import MetadataViews from 0xf8d6e0586b0a20c7

pub contract MultiFungibleToken
{
    pub let MultiFungibleTokenPublicPath  : PublicPath
    pub let MultiFungibleTokenStoragePath : StoragePath

    pub resource MultiFungibleTokenManager: FungibleToken.Receiver
    {
        pub fun deposit(from: @FungibleToken.Vault) // deposit takes a Vault and deposits it into the implementing resource type
        { 
            let type = from.getType()
            let identifier = type.identifier
            var path: PublicPath? = nil


            switch identifier {
                case "A.192440c99cb17282.FUSD.Vault": path = /public/fusdReceiver
            }
            
            let ref = self.owner!.getCapability(path!)!.borrow<&{FungibleToken.Receiver}>() ??  // Get a reference to the recipient's Receiver
                panic("Create a Wallet from: ".concat(identifier))
            ref.deposit(from: <-from)    // Deposit the withdrawn tokens in the recipient's receiver
        }
    }

    init() {
        self.MultiFungibleTokenPublicPath  = MetadataViews.getRoyaltyReceiverPublicPath()
        self.MultiFungibleTokenStoragePath = /storage/MultiFungibleTokenManager
    }
}