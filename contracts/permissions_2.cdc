// permissions.cdc
// Ami Rajpal, 2022 // DAAM Agency // web: daam.agency

/************************************************************************/
pub contract Permissions {
    // Events
    pub event ContractInitialized()

    // Variables
    priv var counterID: UInt64

/************************************************************************/
    // Interfaces
    pub resource interface IAccess {
        pub let holder: Address // owner
        pub let id    : UInt64
        pub let type  : Type
        // Functions
        pub fun compareType(access: &{IAccess}): Bool
    }    
/************************************************************************/
    pub resource Access: IAccess {
        pub let id: UInt64
        pub let holder: Address // owner
        pub let type: Type
        priv var access: UInt256

        init(signer: AuthAccount, type: Type) {
            Permissions.counterID = Permissions.counterID + 1
            self.id = Permissions.counterID
            self.holder = signer.address
            self.type = type
            self.access = 0
        }

        pub fun compareType(access: &{IAccess}): Bool {
            return access.type == self.type
        }
    }    
/************************************************************************/
    pub fun createAccess(type: Type): @Access {        
        return <- create Access(type: type)
    }
/************************************************************************/
   init() {
       self.counterID = 0
       emit ContractInitialized()
	}
}
