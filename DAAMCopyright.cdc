pub contract DAAMCopyright {
    // DAAMCopyright variables
    pub enum CopyrightStatus: Int128 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIFIED
            pub case VERIFIED
    }
    pub var copyrightInformation: {UInt32: String}

    // Copyright (Resource)
    pub resource Copyright {
        pub var copyright_status: CopyrightStatus  // status contains the current Copyright status

        pub fun status(): CopyrightStatus  { return self.copyright_status  }  //  get status        
        init(_ copyright: CopyrightStatus) { self.copyright_status = copyright }  // initialize status

        pub fun createCopyright(_ target: StoragePath) { // Used to create 
            DAAMCopyright.account.save(<- create Copyright(self.copyright_status), to: target)           
        }// createCopyright   
    }
    
    // DAAMCopyright initialization
    init() {
        self.copyrightInformation = {}
        // Fraud
        let Fraud <- create Copyright(CopyrightStatus.FRAUD)
        Fraud.createCopyright(/storage/Fraud)
        destroy Fraud
        // Claim
        let Claim <- create Copyright(CopyrightStatus.CLAIM)
        Claim.createCopyright(/storage/Claim)
        destroy Claim
        // Unverified, basically unknown, no image search
        let Unverified <- create Copyright(CopyrightStatus.UNVERIFIED)
        Unverified.createCopyright(/storage/Unverified)
        destroy Unverified
        // Verified
        let Verified <- create Copyright(CopyrightStatus.VERIFIED)
        Verified.createCopyright(/storage/Verified)
        destroy Verified       
    }//DAAMCopyright init

    pub fun setCopyright(copyright: CopyrightStatus): Capability<&DAAMCopyright.Copyright>? {
        var n = copyright.rawValue as? Int
        switch n {
            case CopyrightStatus.FRAUD.rawValue as? Int:
                return  DAAMCopyright.account.link<&Copyright>(/public/Fraud, target: /storage/Fraud)
            case CopyrightStatus.CLAIM.rawValue as? Int:
                return DAAMCopyright.account.link<&Copyright>(/public/Claim, target: /storage/Claim)
            case CopyrightStatus.UNVERIFIED.rawValue as? Int:
                return DAAMCopyright.account.link<&Copyright>(/public/Unverifed, target: /storage/Unverifed)
            case CopyrightStatus.VERIFIED.rawValue as? Int:
                return DAAMCopyright.account.link<&Copyright>(/public/Verified,  target: /storage/Verified)
            default: return nil
        }   
    } 
    /*access(account) fun getCopyrightInformation(_ id: Uint64): String {
        return copyrightInformation[id]
    }

    access(account) fun setCopyrightInformation(_ id: Uint64, info: String): String {
        return copyrightInformation[id] = info
    }*/

}// DAAMCopyright