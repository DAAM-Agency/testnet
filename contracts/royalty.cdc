pub contract Royalty
{
    // Events
    pub event ContractInitialized()
    pub event GroupInvited(royalty: {Address:UFix64})    
    pub event AgreementReached(royalty: {Address:UFix64})
/***********************************************************************/
    pub resource Percentage {
        pub let signer    : Address          // Owner address
        pub var royalty   : {Address:UFix64} // { Shareholder name: {address:percentage} }
        pub var agreement : {Address:Bool}
        pub var isOpen    : Bool

        init(signer: AuthAccount, royalty: {Address:UFix64}) {
            //pre { self.is100Percent(royalty) : "Royalty entry is invalid." }
            
            self.signer    = signer.address
            self.royalty   = royalty
            self.isOpen    = true
            self.agreement = {}             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
            for r in royalty.keys { self.agreement.insert(key: r, false) }
        }
    
        priv fun is100Percent(_ percentage: {Address:UFix64} ): Bool {
            var total = 0.0
            for p in percentage.keys {
                total = total + percentage[p]!
            }
            return (total == 1.0)
        }   

        pub fun newPercentage(signer: AuthAccount, royalty: {Address:UFix64}): @Percentage {
            let percentage <- create Percentage(signer: signer, royalty: royalty)
            
            log("New Royalty: ".concat(signer.address.toString()))
            emit GroupInvited(royalty: royalty)

            return <- percentage 
        }

        access(contract) fun bargin(signer: AuthAccount, royalty: {Address:UFix64} ) {
            // Verify is Creator
            pre { !self.isValid() : "Neogoation is already closed. Both parties have already agreed."  }
            self.agreement[signer.address] = true
            self.royalty = royalty

            log("Negotiating")
            if self.isValid() {
                log("Agreement Reached")
                emit AgreementReached(royalty: royalty)
            }
        }

        pub fun isValid(): Bool {
            for r  in self.royalty.keys {
                if self.agreement[r] == false { return false}
            }
            return true 
        }

        priv fun royaltyMatch(_ royalities: {Address:UFix64} ): Bool {
            if self.royalty.length != royalities.length { return false}
            for royalty in royalities.keys {
                if royalities[royalty] != self.royalty[royalty] { return false }
            }
            return true
        }
    }
/***********************************************************************/
    init() { emit ContractInitialized() }
 } 
// END Royalty
/***********************************************************************



    // Used to create Request Resources. Metadata ID is passed into Request.
    // Request handle Royalities, and Negoatons.
    pub resource RequestGenerator {
        priv let grantee: Address

        init(_ grantee: Address) { self.grantee = grantee }
        // Accept the default Request. No Neogoation is required.
        // Percentages are between 10% - 30%
        pub fun acceptDefault(creator: AuthAccount, metadata: &Metadata, percentage: UFix64) {
            pre {
                self.grantee == creator.address            : "Permission Denied"
                DAAM.creators.containsKey(creator.address) : "You are not a Creator"
                DAAM.creators[creator.address]!            : "Your Creator account is Frozen."
                percentage >= 0.1 && percentage <= 0.3     : "Percentage must be inbetween 10% to 30%."
            }

            var royalty = {creator.address: (0.1 * percentage) }  // Get Agency percentage, Agency takes 10% of Creator
            royalty.insert(key: self.owner?.address!, (0.9 * percentage) ) // Get Creator Percentage

            let request <-! create Request(metadata: metadata) // Get request
            request.acceptDefault(royalty: royalty)          // Append royalty rate

            let old <- DAAM.request.insert(key: mid, <-request) // Advice DAAM of request
            destroy old // destroy place holder
            
            log("Request Accepted, MID: ".concat(mid.toString()) )
            emit RequestAccepted(mid: mid)
        }
    }

    /***********************************************************************/
    // Used to make requests for royalty. A resource for Neogoation of royalities.
    // When both parties agree on 'royalty' the Request is considered valid aka isValid() = true and
    // Neogoation may not continue. V2 Featur TODO
    // Request manage the royalty rate
    // Accept Default are auto agreements
    pub resource Request {
        access(contract) let mid       : UInt64                // Metadata ID number is stored
        access(contract) var royalty  : {Address : UFix64}    // current royalty neogoation.
        acc`ess(contract) var agreement : [Bool; 2]             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
        
        init(metadata: &Metadata) {
            self.mid       = metadata.mid    // Get Metadata ID
            DAAM.metadata[self.mid] != false // Can set a Request as long as the Metadata has not been Disapproved as oppossed to Aprroved or Not Set.
            self.royalty  = {}              // royalty is initialized
            self.agreement = [false, false]  // [Agency/Admin, Creator] are both set to disagree by default
        }

    pub resource Request {
    access(contract) let mid       : UInt64                // Metadata ID number is stored
    access(contract) var royalty  : {Address : UFix64}    // current royalty neogoation.
    access(contract) var agreement : [Bool; 2]             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
    
    init(metadata: &Metadata) {
        self.mid       = metadata.mid    // Get Metadata ID
        DAAM_V7.metadata[self.mid] != false // Can set a Request as long as the Metadata has not been Disapproved as oppossed to Aprroved or Not Set.
        self.royalty  = {}              // royalty is initialized
        self.agreement = [false, false]  // [Agency/Admin, Creator] are both set to disagree by default
    }

    // If both parties agree (Creator & Admin) return true
    pub fun isValid(): Bool { return self.agreement[0]==true && self.agreement[1]==true }
    */
