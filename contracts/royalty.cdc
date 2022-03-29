pub contract Royalty
{
    // Events
    pub event ContractInitialized()
    pub event GroupInvited(group_name: String)    
/***********************************************************************/
    pub struct Group {
        pub let signer     : Address                      // Owner address
        pub let group_name : String                       // Group group_name
        pub let royalty    : {String : {Address:UFix64} } // { Shareholder name: {address:percentage} }

        init(signer: AuthAccount, group_name: String, royalty: {String : {Address:UFix64} } ) {
            //pre { Royalty.verifyRoyalty(royalty) : "Royalty entry is invalid." }
            self.signer = signer.address
            self.group_name = group_name
            self.royalty = royalty
        }
        
    }
/***********************************************************************/
    // Variables
    priv var group : {String : Group}
/***********************************************************************/
    // Functions
    pub fun getGroup(group_name: String): Group? {
        return self.group[group_name]
    }
/***********************************************************************/
    priv fun validatePercentage(group_name: String, percentage: UFix64): Bool { return true }     
/***********************************************************************/     
    pub fun request(group_name: String, percentage: UFix64): Group { // Save Royalty
        pre {
            self.group.containsKey(group_name) : "This Group does not exist."
            self.validatePercentage(group_name: group_name, percentage: percentage) : "Percentage is invalid."
        }
        // Insert percentage here
        base = self.group[group_name].base

        
        return self.group[group_name]!
    } 
/***********************************************************************/     
    pub fun newGroup(signer: AuthAccount, group_name: String, royalty: {String : {Address:UFix64}} ) {
        pre {
            // must be Alpha-numeric
            // group_name: first/last character must be Alpha-numeric
            // group_name: set to upper-case
            // can not contain 2 spaces concerntly
            !self.group.containsKey(group_name) : "Name is already taken"
        }
        post { self.group.containsKey(group_name) : "Illegal Operation" }

        let group = Group(signer: signer, group_name: group_name, royalty: royalty)
        self.group.insert(key: group_name, group)

        log("New Royalty: ".concat(group_name) )
        emit GroupInvited(group_name: group_name)      
    }
/***********************************************************************/
    init() {
        self.group = {}
        emit ContractInitialized()
    }
} // END Royalty
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

            var royality = {creator.address: (0.1 * percentage) }  // Get Agency percentage, Agency takes 10% of Creator
            royality.insert(key: self.owner?.address!, (0.9 * percentage) ) // Get Creator Percentage

            let request <-! create Request(metadata: metadata) // Get request
            request.acceptDefault(royality: royality)          // Append royality rate

            let old <- DAAM.request.insert(key: mid, <-request) // Advice DAAM of request
            destroy old // destroy place holder
            
            log("Request Accepted, MID: ".concat(mid.toString()) )
            emit RequestAccepted(mid: mid)
        }
    }

    /***********************************************************************/
    // Used to make requests for royality. A resource for Neogoation of royalities.
    // When both parties agree on 'royality' the Request is considered valid aka isValid() = true and
    // Neogoation may not continue. V2 Featur TODO
    // Request manage the royality rate
    // Accept Default are auto agreements
    pub resource Request {
        access(contract) let mid       : UInt64                // Metadata ID number is stored
        access(contract) var royality  : {Address : UFix64}    // current royality neogoation.
        access(contract) var agreement : [Bool; 2]             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
        
        init(metadata: &Metadata) {
            self.mid       = metadata.mid    // Get Metadata ID
            DAAM.metadata[self.mid] != false // Can set a Request as long as the Metadata has not been Disapproved as oppossed to Aprroved or Not Set.
            self.royality  = {}              // royality is initialized
            self.agreement = [false, false]  // [Agency/Admin, Creator] are both set to disagree by default
        }

    pub resource Request {
    access(contract) let mid       : UInt64                // Metadata ID number is stored
    access(contract) var royality  : {Address : UFix64}    // current royality neogoation.
    access(contract) var agreement : [Bool; 2]             // State os agreement [Admin (agrees/disagres),  Creator(agree/disagree)]
    
    init(metadata: &Metadata) {
        self.mid       = metadata.mid    // Get Metadata ID
        DAAM_V7.metadata[self.mid] != false // Can set a Request as long as the Metadata has not been Disapproved as oppossed to Aprroved or Not Set.
        self.royality  = {}              // royality is initialized
        self.agreement = [false, false]  // [Agency/Admin, Creator] are both set to disagree by default
    }

    // If both parties agree (Creator & Admin) return true
    pub fun isValid(): Bool { return self.agreement[0]==true && self.agreement[1]==true }
    */
