pub contract DAAMCopyright {
    // DAAMCopyright variables
    pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIFIED
            pub case VERIFIED
    }
    pub var copyrightInformation: {UInt32: String}

    pub resource Copyright {
        pub var copyright_status: CopyrightStatus  // status contains the current Copyright status
        pub fun status(): CopyrightStatus  { return self.copyright_status  }  //  get status        
        init(_ copyright: CopyrightStatus) { self.copyright_status = copyright }  // initialize status
        pub fun createCopyright(_ target: StoragePath) { // Used to create 
            DAAMCopyright.account.save(<- create Copyright(self.copyright_status), to: target)           
        }// Copyright   
    }

    init() {
        self.copyrightInformation = {}
        // Fraud
        let Fraud <- create Copyright(CopyrightStatus.FRAUD)
        Fraud.createCopyright(/storage/Fraud)
        self.account.link<&Copyright>(/public/Fraud, target: /storage/Fraud)
        destroy Fraud

        // Claim
        let Claim <- create Copyright(CopyrightStatus.CLAIM)
        Claim.createCopyright(/storage/Claim)
        self.account.link<&Copyright>(/public/Claim, target: /storage/Claim)        
        destroy Claim

        // Unverified, basically unknown, no image search
        let Unverified <- create Copyright(CopyrightStatus.UNVERIFIED)
        Unverified.createCopyright(/storage/Unverified)
        self.account.link<&Copyright>(/public/Unverified, target: /storage/Unverified)
        destroy Unverified

        // Verified
        let Verified <- create Copyright(CopyrightStatus.VERIFIED)
        Verified.createCopyright(/storage/Verified)
        self.account.link<&Copyright>(/public/Verified, target: /storage/Verified)
        destroy Verified       
    }// DAAMCopyright init

    pub fun setCopyright(copyright: CopyrightStatus): &DAAMCopyright.Copyright {
        var n = copyright.rawValue as? Int
        switch n {
            case CopyrightStatus.FRAUD.rawValue as? Int: return self.account.getCapability<&Copyright>(/public/Fraud).borrow()!                 
            case CopyrightStatus.CLAIM.rawValue as? Int: return self.account.getCapability<&Copyright>(/public/Claim).borrow()!     
            case CopyrightStatus.UNVERIFIED.rawValue as? Int: return self.account.getCapability<&Copyright>(/public/Unverifed).borrow()!     
            case CopyrightStatus.VERIFIED.rawValue as?   Int: return self.account.getCapability<&Copyright>(/public/Verified).borrow()!     
            default: return nil!
        }
    } 
    /*access(account) fun getCopyrightInformation(_ id: Uint64): String {
        return copyrightInformation[id]
    }

    access(account) fun setCopyrightInformation(_ id: Uint64, info: String): String {
        return copyrightInformation[id] = info
    }*/

}// DAAMCopyright