import FungibleToken from 0x9a0766d93b6608b7
import MetadataViews from 0x631e88ae7f1d7c20 // Only used for initializing MultiFungibleTokenReceiverPath

// Supported FungibleTokens
import FUSD from 0xba1132bc08f82fe2

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
            let ftInfo = MultiFungibleToken.getFungibleTokenInfo(type) 

            if ftInfo == nil {
                self.storeDeposit(<-from)
                emit CreateNewWallet(user: self.owner!.address, type: type, amount: balance)
                return
            }
            
            let ref = self.owner!.getCapability(ftInfo!.publicPath!)!.borrow<&{FungibleToken.Receiver}>() // Get a reference to the recipient's Receiver
            if (ref == nil) {
                self.storeDeposit(<-from)
                emit CreateNewWallet(user: self.owner!.address, type: type, amount: balance)
                return
            }

            ref!.deposit(from: <-from)    // Deposit the withdrawn tokens in the recipient's receiver
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
            let ref = &mft.storage[identifier] as &FungibleToken.Vault?
            let type = ref!.getType()
            let ftInfo = MultiFungibleToken.getFungibleTokenInfo(type)
            
            if ftInfo == nil { continue }
            switch identifier
            {
                case "A.ba1132bc08f82fe2.FUSD.Vault":
                    if owner.borrow<&FUSD.Vault{FungibleToken.Receiver}>(from: ftInfo!.storagePath) == nil {
                            owner.save(<-FUSD.createEmptyVault(), to: ftInfo!.storagePath)
                            owner.link<&FUSD.Vault{FungibleToken.Receiver}>(ftInfo!.publicPath, target: ftInfo!.storagePath)
                    }

                /*case "A.ec4809cd812aee0a.TokenA.Vault":
                    if owner.borrow<&TokenA.Vault{FungibleToken.Receiver}>(from: ftInfo!.storagePath) == nil {
                            owner.save(<-TokenA.createEmptyVault(), to: ftInfo!.storagePath)
                            owner.link<&TokenA.Vault{FungibleToken.Receiver}>(ftInfo!.publicPath, target: ftInfo!.storagePath)
                    }*/
            }
            let coins <- mft.removeDeposit(identifier)
            mft.deposit(from: <- coins)
        }
    }

    access(contract) fun getFungibleTokenInfo(_ type: Type): FungibleTokenVaultInfo? {
        let identifier = type.identifier
        var publicPath : PublicPath?  = nil
        var storagePath: StoragePath? = nil

        switch identifier {
                /* FUSD   */ case "A.ba1132bc08f82fe2.FUSD.Vault": publicPath = /public/fusdReceiver; storagePath = /storage/fusdVault;
                ///* TokenA */ case "A.ec4809cd812aee0a.TokenA.Vault" : log("B"); publicPath = /public/tokenAReceiver; storagePath = /storage/tokenAVault
        }
        return (publicPath != nil && storagePath != nil) ? FungibleTokenVaultInfo(type: type, identifier: identifier, publicPath: publicPath!, storagePath: storagePath!) : nil
    }    
    // Contract Init ---------------------------------------------------------------------------------
    init() {
        self.MultiFungibleTokenReceiverPath  = MetadataViews.getRoyaltyReceiverPublicPath()
        self.MultiFungibleTokenStoragePath   = /storage/MultiFungibleTokenManager
        self.MultiFungibleTokenBalancePath   = /public/MultiFungibleTokenBalance
    }
}