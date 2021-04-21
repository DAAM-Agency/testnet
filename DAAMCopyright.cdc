pub contract DAAMCopyright {
    
    pub enum CopyrightStatus: UInt8 {
            pub case Fraud
            pub case Claim
            pub case Unverified
            pub case Verified
    }

    pub var copyrightInformation: {UInt32: String} 

    pub resource interface Copyright {
        pub let status: CopyrightStatus
        pub fun status(): CopyrightStatus
        init(_ status: CopyrightStatus) { self.status = status }
    }

    // Types of Copyright statuses
    access(contract) resource Fraud:      Copyright { init(CopyrightStatus.Fraud)      }
    access(contract) resource Claim:      Copyright { init(CopyrightStatus.Claim)      }
    access(contract) resource Unverified: Copyright { init(CopyrightStatus.Unverified) }
    access(contract) resource Verified:   Copyright { init(CopyrightStatus.Verified)   }

    pub getCopyrightInfo(id: UInt32): String { return copyrightInformation[id] }

    init() {
        AuthAccount.save(<- create Fraud(),      to: /storage/Copyright/Fraud)
        AuthAccount.save(<- create Claim(),      to: /storage/Copyright/Claim)
        AuthAccount.save(<- create Unverified(), to: /storage/Copyright/Unverifed)
        AuthAccount.save(<- create Verified(),   to: /storage/Copyright/Verified)

        AuthAccount.link<&{Copyright}>(/public/Copyright/Fraud,      target: /storage/Copyright/Fraud)
        AuthAccount.link<&{Copyright}>(/public/Copyright/Claim,      target: /storage/Copyright/Claim)
        AuthAccount.link<&{Copyright}>(/public/Copyright/Unverified, target: /storage/Copyright/Unverified)
        AuthAccount.link<&{Copyright}>(/public/Copyright/Verified,   target: /storage/Copyright/Verified)
    }
}