import FungibleToken from 0xee82856bf20e2aa6
import MetadataViews from 0xf8d6e0586b0a20c7 // Only used for initializing MultiFungibleTokenReceiverPath
// Supported FungibleTokens
import FUSD from 0x192440c99cb17282

pub contract MultiFungibleToken
{
    // Events ---------------------------------------------------------------------------------
    pub event CreateNewWallet(user: Address, type: Type, amount: UFix64)
    // Paths  ---------------------------------------------------------------------------------
    pub let MultiFungibleTokenReceiverPath : PublicPath
    pub let MultiFungibleTokenBalancePath  : PublicPath
    pub let MultiFungibleTokenStoragePath  : StoragePath
    //Structs ---------------------------------------------------------------------------------
    pub struct FungibleTokenVaultInfo {
        pub let type       : Type
        pub let identifier : String
        pub let publicPath : PublicPath
        pub let storagePath: StoragePath

        init(type: Type, identifier: String, publicPath: PublicPath, storagePath: StoragePath) {
            self.type        = type
            self.identifier  = identifier
            self.publicPath  = publicPath
            self.storagePath = storagePath
        }
    }
    // Interfaces ---------------------------------------------------------------------------------
    pub resource interface MultiFungibleTokenBalance {
        pub fun getBalances(): {String : UFix64}
    }
    // Resources ---------------------------------------------------------------------------------
    pub resource MultiFungibleTokenManager: FungibleToken.Receiver, MultiFungibleTokenBalance {
        access(contract) var storage: @{String : FungibleToken.Vault}
        access(contract) var balance: {String : UFix64}

        init() {
            self.storage <- {}
            self.balance =  {}
        }

        pub fun deposit(from: @FungibleToken.Vault) // deposit takes a Vault and deposits it into the implementing resource type
        { 
            let type = from.getType()
            let identifier = type.identifier
            let balance = from.balance
            var ftInfo = MultiFungibleToken.getFungibleTokenInfo(type, identifier) ?? panic(identifier.concat(" is not accepted."))
            
            var ref = self.owner!.getCapability(ftInfo.publicPath!)!.borrow<&{FungibleToken.Receiver}>() // Get a reference to the recipient's Receiver
            if (ref != nil) {
                ref!.deposit(from: <-from)    // Deposit the withdrawn tokens in the recipient's receiver
            } else {
                self.storeDeposit(<-from)
                emit CreateNewWallet(user: self.owner.address, type: type, amount: balance)
            }
        }

        priv fun storeDeposit(_ from: @FungibleToken.Vault) {
            let type = from.getType()
            let identifier = type.identifier

            if self.storage.containsKey(identifier) {          
                let vault <- self.storage.remove(key:identifier)
                from.deposit(from: <- vault!)
            }
            self.balance[identifier] = from.balance            
            let old <- self.storage.insert(key: identifier, <-from)
            destroy old
        }

        access(contract) fun removeDeposit(_ identifier: String): @FungibleToken.Vault {
            pre  { self.storage.containsKey(identifier)  : "Incorrent identifier: ".concat(identifier) }
            post { !self.storage.containsKey(identifier) : "Illegal Operation: removeDeposit, identifier: ".concat(identifier) }
            let coins <- self.storage.remove(key: identifier)!
            return <- coins
        }

        pub fun getBalances(): {String: UFix64} {
            return self.balance
        }

        destroy() { destroy self.storage }
    }
    // Contract Functions ---------------------------------------------------------------------------------
    pub fun createEmptyMultiFungibleTokenReceiver(): @MultiFungibleTokenManager {
        return <- create MultiFungibleTokenManager()
        //return <- mftm
    }

    access(contract) fun getFungibleTokenInfo(_ type: Type): FungibleTokenVaultInfo? {
        let identifier = type.identifier
        switch identifier {
                /* FUSD */ case "A.192440c99cb17282.FUSD.Vault": return FungibleTokenVaultInfo(type: type, identifier: identifier, publicPath: /public/fusdReceiver, storagePath: /storage/fusdVault)
        }
        return nil
    }

    access(contract) fun createMissingWalletsAndDeposit(_ owner: AuthAccount, _ mft: &MultiFungibleTokenManager) {
        for identifier in mft.storage.keys {          
            var ftInfo = MultiFungibleToken.getFungibleTokenInfo(mft.storage[identifier].getType()) ?? panic(identifier.concat(" is not accepted."))
            switch identifier {
                    case "A.192440c99cb17282.FUSD.Vault":
                    if owner.borrow<&FUSD.Vault{FungibleToken.Receiver}>(from: ftInfo.storagePath) == nil {
                            owner.save(<-FUSD.createEmptyVault(), to: ftInfo.storagePath)
                            owner.link<&FUSD.Vault{FungibleToken.Receiver}>(ftInfo.publicPath, target: ftInfo.storagePath)
                        }
                    let coins <- mft.removeDeposit(identifier)
                    mft.deposit(from: <- coins)
            }
        }
    }
    // Contract Init ---------------------------------------------------------------------------------
    init() {
        self.MultiFungibleTokenReceiverPath  = MetadataViews.getRoyaltyReceiverPublicPath()
        self.MultiFungibleTokenStoragePath   = /storage/MultiFungibleTokenManager
        self.MultiFungibleTokenBalancePath   = /public/MultiFungibleTokenBalance
    }
}