pub contract DAAMCopyright {
    // DAAMCopyright variables
    pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIDFIED
            pub case VERIDIED
    }
    pub var copyrightInformation: {UInt32: String}

    // DAAMCopyright function (Do we really need this ?!?)
    //pub fun getCopyrightInfo(id: UInt32): String { return self.copyrightInformation[id] }

    // Copyright (Resource)
    pub resource Copyright {
        pub var copyright_status: CopyrightStatus  // status contains the current Copyright status
        pub fun status(): CopyrightStatus  { return self.copyright_status  }  //  get status
        
        init(_ copyright: CopyrightStatus) { self.copyright_status = copyright } // initialize status

        pub fun createCopyright(_ target: StoragePath) { // Used to create 
            DAAMCopyright.account.save(<- create Copyright(self.copyright_status), to: target)
        }       
    }
    
    // DAAMCopyrigt initialization
    init() {
        self.copyrightInformation = {}
        
        let Fraud <- create Copyright(CopyrightStatus.FRAUD)
        Fraud.createCopyright(/storage/Fraud)
        destroy Fraud
        //let Claim <- Copyright.createCopyright(CopyrightStatus.CLAIM, target: storage/claim)
        //let Unverified <- Copyright.createCopyright(CopyrightStatus.UNVERIDFIED, target: storage/unverified)
        //let Verified   <- Copyright.createCopyright(CopyrightStatus.VERIDIED,    target: storage/verified)
    }

    /*fun setCopyrightCap(status: CopyrightStatus, ): Capability<{CopyrightInterface}> {
        access(contract) var storagePath: StoragePath
        switch self.copyright_status {
            case CopyrightStatus.Fraud: storagePath = /storage/Fraud
            case CopyrightStatus.Claim: storagePath = /storage/Claim
            case CopyrightStatus.Unverified: storagePath = /storage/Unverified
            case CopyrightStatus.Verified:   storagePath = /storage/Verified
        }
        self.copyrightInformation[] = 
        return self.account.link<{&CopyrightInterface}>(storagePath , target: /public/Copyright)!
        }*/
}