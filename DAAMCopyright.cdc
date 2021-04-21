pub contract DAAMCopyright {
    
    pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIDFIED
            pub case VERIDIED
    }

    //pub var copyrightInformation: {UInt32: String} 

    pub resource Copyright {
        access(self) var copyright_status: CopyrightStatus
        pub fun status(): CopyrightStatus  { return self.copyright_status  }
        init(_ copyright: CopyrightStatus, target: StoragePath) {
            self.copyright_status = copyright
            let newHello <- create Copyright(self.copyright_status, target: target)
            DAAMCopyright.account.save(<-newHello, to: target)
        }
    }

    // Types of Copyright statuses
    //let Fraud: @Copyright <- create Copyright(CopyrightStatus.FRAUD, /storage/Fraud)
    //pub resource Claim: CopyrightInterface      {pub fun status(): CopyrightStatus {return CopyrightStatus.Claim}}
    //pub resource Unverified: CopyrightInterface {pub fun status(): CopyrightStatus {return CopyrightStatus.Unverified}}
    //pub resource Verified: CopyrightInterface   {pub fun status(): CopyrightStatus {return CopyrightStatus.Verified}}

    //pub fun getCopyrightInfo(id: UInt32): String { return self.copyrightInformation[id]? }

    //init() {
        //self.copyrightInformation = {}
        //self.account.save(<- create Fraud(), to: /storage/Fraud)
        //self.account.save(<- create Claim(), to: /storage/Claim)
        //self.account.save(<- create Unverified(), to: /storage/Unverifed)
        //self.account.save(<- create Verified(),   to: /storage/Verified)
    //}

    /*access(self) fun setCopyrightCap(status: CopyrightStatus): Capability<CopyrightInterface> {
    // Test the value of the parameter `n`
        switch status {
        case CopyrightStatus.Fraud:
            // If the value of variable `n` is equal to `1`,
            // then return the string "one"
            return self.account.link<{&CopyrightInterface}>(/public/Copyright, target: /storage/Fraud)
        /*case CopyrightStatus.Claim:
            // If the value of variable `n` is equal to `2`,
            // then return the string "two"
            return "two"
        case CopyrightStatus.Unverified:
            // If the value of variable `n` is equal to `2`,
            // then return the string "two"
            return "two"
        case CopyrightStatus.Verified:
            // If the value of variable `n` is neither equal to `1` nor to `2`,
            // then return the string "other"
            return "other"*/
        }
        return 
    }*/


  
        //return self.account.link<&{CopyrightInterface}>(/public/Copyright, target: /storage/Fraud)
    
        //AuthAccount.link<&{Copyright}>(/public/Copyright/Claim,      target: /storage/Copyright/Claim)
        //AuthAccount.link<&{Copyright}>(/public/Copyright/Unverified, target: /storage/Copyright/Unverified)
        //AuthAccount.link<&{Copyright}>(/public/Copyright/Verified,   target: /storage/Copyright/Verified)
    
}