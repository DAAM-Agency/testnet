pub contract Royalty
{
    // Events
    event GroupInvited(name: String)    
/***********************************************************************/
    pub struct Group {
        pub let signer : Address
        pub let name    : String
        pub let royalty : {Address : [UFix64]}

        init(signer: AuthAccount, name: String, royalty: {Address:[UFix64]} )
    }
/***********************************************************************/
    priv var group : {String : Group}
/***********************************************************************/
    pub fun getGroup(name: String): {Address:[UFix64]}? {
        return self.group[name]
    }
/***********************************************************************/     
    pub fun newGroup(signer: Authaccount, name: String, royalty: {Address:[UFix64]} ) {    // Admin or Agent invite a new creator
        pre {
            // name: first/last character must be Alpha-numeric
            // name: set to upper-case
            !self.group.containsKey(name) : "Name is already taken"
        }
        post { self.group.containsKey(name) : "Illegal Operation" }

        self.group.insert(key: name, new Group(signer: signer, name: name, royalty: royalty) )

        log("New Royalty: ".concat(name) )
        emit GroupInvited(name: name)      
    }
/***********************************************************************/
init() {
    self.group = {}
}
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

    /***********************************************************************
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
