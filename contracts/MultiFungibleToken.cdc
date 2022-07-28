import FungibleToken from 0x9a0766d93b6608b7
import MetadataViews from 0x631e88ae7f1d7c20 // Only used for initializing MultiFungibleTokenReceiverPath
// Supported FungibleTokens
import FUSD from 0xe223d8a629e49c68

pub contract MultiFungibleToken
{
    // Events ---------------------------------------------------------------------------------
    pub event CreateNewWallet(user: Address, type: Type, amount: UFix64)
    // Paths  ---------------------------------------------------------------------------------
    pub let MultiFungibleTokenReceiverPath : PublicPath
    pub let MultiFungibleTokenBalancePath  : PublicPath
    pub let MultiFungibleTokenStoragePath  : StoragePath
    //Structs ---------------------------------------------------------------------------------
    pub struct FungibleTokenVaultInfo { // Fungible Token Vault Basic Information, unique to each FT
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
    pub resource interface MultiFungibleTokenBalance { // An interface to get all the balances in storage
        pub fun getStorageBalances(): {String : UFix64}
    }
    // Resources ---------------------------------------------------------------------------------
    pub resource MultiFungibleTokenManager: FungibleToken.Receiver, MultiFungibleTokenBalance {
        access(contract) var storage: @{String : FungibleToken.Vault}

        init() {
            self.storage <- {}
        }

        pub fun deposit(from: @FungibleToken.Vault) // deposit takes a Vault and deposits it into the implementing resource type
        { 
            let type = from.getType()
            let identifier = type.identifier
            let balance = from.balance
            let ftInfo = MultiFungibleToken.getFungibleTokenInfo(type) ?? panic(identifier.concat(" is not accepted."))
            
            let ref = self.owner!.getCapability(ftInfo.publicPath!)!.borrow<&{FungibleToken.Receiver}>() // Get a reference to the recipient's Receiver
            if (ref != nil) {
                ref!.deposit(from: <-from)    // Deposit the withdrawn tokens in the recipient's receiver
            } else {
                self.storeDeposit(<-from)
                emit CreateNewWallet(user: self.owner!.address, type: type, amount: balance)
            }
        }

        priv fun storeDeposit(_ from: @FungibleToken.Vault) {
            let type = from.getType()
            let identifier = type.identifier

            if !self.storage.containsKey(identifier) {
                let old <- self.storage.insert(key: identifier, <-from)
                destroy old
            } else {
                let ref = &self.storage[identifier] as &FungibleToken.Vault?
                ref!.deposit(from: <- from)
            }
        }

        access(contract) fun removeDeposit(_ identifier: String): @FungibleToken.Vault {
            pre  { self.storage.containsKey(identifier)  : "Incorrent identifier: ".concat(identifier) }
            post { !self.storage.containsKey(identifier) : "Illegal Operation: removeDeposit, identifier: ".concat(identifier) }
            return <- self.storage.remove(key: identifier)!
        }

        pub fun getStorageBalances(): {String: UFix64} {
            var balances: {String : UFix64} = {}            
            for coin in self.storage.keys {
                let ref = &self.storage[coin] as &FungibleToken.Vault?
                let balance = ref?.balance!
                balances.insert(key: coin, balance)
            }
            return balances
        }

        destroy() { destroy self.storage }
    }
    // Contract Functions ---------------------------------------------------------------------------------
    pub fun createEmptyMultiFungibleTokenReceiver(): @MultiFungibleTokenManager {
        return <- create MultiFungibleTokenManager()
    }

    pub fun createMissingWalletsAndDeposit(_ owner: AuthAccount, _ mft: &MultiFungibleTokenManager) {
        for identifier in mft.storage.keys {          
            let ftInfo = MultiFungibleToken.getFungibleTokenInfo(mft.storage[identifier].getType()) ?? panic(identifier.concat(" is not accepted."))
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

    access(contract) fun getFungibleTokenInfo(_ type: Type): FungibleTokenVaultInfo? {
        let identifier = type.identifier
        switch identifier {
                /* FUSD */ case "A.e223d8a629e49c68.FUSD.Vault": return FungibleTokenVaultInfo(type: type, identifier: identifier, publicPath: /public/fusdReceiver, storagePath: /storage/fusdVault)
        }
        return nil
    }    
    // Contract Init ---------------------------------------------------------------------------------
    init() {
        self.MultiFungibleTokenReceiverPath  = MetadataViews.getRoyaltyReceiverPublicPath()
        self.MultiFungibleTokenStoragePath   = /storage/MultiFungibleTokenManager
        self.MultiFungibleTokenBalancePath   = /public/MultiFungibleTokenBalance
    }
}