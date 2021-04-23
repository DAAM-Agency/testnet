pub contract DAAMCopyright {
    // DAAMCopyright variables
    pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIDFIED
            pub case VERIDIED
    }
    pub var copyrightInformation: {UInt32: String}

    // Copyright (Resource)
    pub resource Copyright {
        pub var copyright_status: CopyrightStatus  // status contains the current Copyright status
        pub fun status(): CopyrightStatus  { return self.copyright_status  }  //  get status
        
        init(_ copyright: CopyrightStatus) {
            self.copyright_status = copyright // initialize status
        }

        pub fun createCopyright(_ target: StoragePath) { // Used to create 
            DAAMCopyright.account.save(<- create Copyright(self.copyright_status), to: target)
        }       
    }
    
    // DAAMCopyrigt initialization
    init() {
        self.copyright_status = CopyrightStatus.Unverified
        self.copyrightInformation = {}
        // Frauf
        let Fraud <- create Copyright(CopyrightStatus.FRAUD)
        Fraud.createCopyright(/storage/Fraud)
        destroy Fraud
        // Claim
        let Claim <- create Copyright(CopyrightStatus.CLAIM)
        Claim.createCopyright(/storage/Claim)
        destroy Claim
        // Unverified, basically unknown, no image search
        let Unverified <- create Copyright(CopyrightStatus.UNVERIDFIED)
        Unverified.createCopyright(/storage/Unverified)
        destroy Unverified
        // Verified
        let Verified <- create Copyright(CopyrightStatus.VERIDIED)
        Verified.createCopyright(/storage/Verified)
        destroy Verified
    }//DAAMCopyrigt init

    pub fun setCopyrightCapability(_ copyright_status: CopyrightStatus): Capability<Copyright> {
        //var storagePath: StoragePath   /// BUG !!!!
        var bgg = 3
        var b = 3
        switch copyright_status {
            case CopyrightStatus.Fraud: storagePath = /storage/Fraud
            case CopyrightStatus.Claim: storagePath = /storage/Claim
            case CopyrightStatus.Unverified: storagePath = /storage/Unverified
            case CopyrightStatus.Verified:   storagePath = /storage/Verified
        }
        return self.account.link<{&CopyrightInterface}>(storagePath , target: /public/Copyright)!
    }

    /*access(account) fun getCopyrightInformation(_ id: Uint64): String {
        return copyrightInformation[id]
    }

    access(account) fun setCopyrightInformation(_ id: Uint64, info: String): String {
        return copyrightInformation[id] = info
    }*/

}// DAAMCopyrigt