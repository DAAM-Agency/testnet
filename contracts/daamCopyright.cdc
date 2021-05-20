pub contract DAAMCopyright {
    // DAAMCopyright variables
  
  /*******************************************************************/
  pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIFIED
            pub case VERIFIED
    }
    pub var copyrightInformation: {UInt64: CopyrightStatus}
  /*******************************************************************/
    pub resource Copyright {
        pub fun status(tokenID: UInt64): CopyrightStatus {
            pre { DAAMCopyright.copyrightInformation[tokenID] != nil : "Invalid NFT ID" }
            return DAAMCopyright.copyrightInformation[tokenID]!
        }
    }
  /*******************************************************************/
    init() {
        self.copyrightInformation = {}
        // Fraud
        let Fraud <- create Copyright()
        self.account.save(<- Fraud, to: /storage/Fraud)
        self.account.link<&Copyright>(/public/Fraud, target: /storage/Fraud)

        // Claim
        let Claim <- create Copyright()
        self.account.save(<- Claim, to: /storage/Claim)
        self.account.link<&Copyright>(/public/Claim, target: /storage/Claim)        

        // Unverified, basically unknown, no image search
        let Unverified <- create Copyright()
        self.account.save(<- Unverified, to: /storage/Unverified)
        self.account.link<&Copyright>(/public/Unverified, target: /storage/Unverified)

        // Verified
        let Verified <- create Copyright()
        self.account.save(<- Verified, to: /storage/Verified)
        self.account.link<&Copyright>(/public/Verified, target: /storage/Verified)
    }// DAAMCopyright init

    pub fun getCopyrightRef(copyright: CopyrightStatus): &DAAMCopyright.Copyright {
        var n = copyright.rawValue as? Int
        switch n {
            case CopyrightStatus.FRAUD.rawValue as? Int: return self.account.getCapability<&Copyright>(/public/Fraud).borrow()!                 
            case CopyrightStatus.CLAIM.rawValue as? Int: return self.account.getCapability<&Copyright>(/public/Claim).borrow()!     
            case CopyrightStatus.UNVERIFIED.rawValue as? Int: return self.account.getCapability<&Copyright>(/public/Unverifed).borrow()!     
            case CopyrightStatus.VERIFIED.rawValue as?   Int: return self.account.getCapability<&Copyright>(/public/Verified).borrow()!     
            default: return nil!
        }
    }
}// DAAMCopyright