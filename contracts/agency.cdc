// agency.cdc
// By Ami Rajpal, DAAM Agency // 2021

pub contract AgencyHQ {
    // Events: AgencyHQ
    pub event ContractInitialized()
    pub event AddAgency(aid: UInt64)
    pub event RemoveAgency(aid: UInt64)
    // Events: Agency
    pub event AgencyCreated(aid: UInt64, name: String)
    pub event ChangeCreatorStatus(creator: Address, status: Bool)
    pub event NewFounder(agency: UInt64, founder: Address)
    pub event NewAdmin(agency: UInt64, admin: Address)
    // Events: Founder
    pub event CreatedNewFounder(founder: UInt64)
    pub event FounderInvited(founder  : Address)
    pub event RemovedFounderInvite()
    pub event AdminInvited(admin  : Address)
    pub event RemovedAdminInvite()
    // Events: Admin
    pub event ChangeAdminSetting()
    pub event CreatorInvited(creator: Address)
    pub event CreatorRemoved(creator: Address)
    pub event ChangedCopyright(metadataID: UInt64)
    // Events: Vote
    pub event VoteInSession(agency: UInt64)
    pub event VoteEntry(agency: UInt64)
    pub event CountingVotes()
    pub event VoteResult(result: Bool)
    
    // Variables
    priv var agency: {UInt64 : Bool}             // {AID:Status} // {Agency ID:(Active/Inactive)}
    access(contract) var agencyCounter : UInt64   // Agency counter for Agency ID (aid)
    access(contract) var founderCounter: UInt64   // Founder counter for Founder ID (fid)
    pub var copyright: {UInt64: CopyrightStatus} // {MID : CopyrightStatus}

    // Storage
    pub let agencyPublicPath  : PublicPath
    pub let agencyStoragePath : StoragePath
    pub let founderPrivatePath: PrivatePath
    pub let founderStoragePath: StoragePath    
/***********************************************************************/
    pub resource Agency {
        pub let aid: UInt64                           // Agency ID
        pub let name: String
        pub var mid: [UInt64]                         // Metadata ID
        access(contract) let percentage: UFix64       // TODO make var and adjustable via Vote
        access(contract) var voting : Bool            // A vote is in session  
        access(contract) var founder: {UInt64 : UFix64} // {FID : percentage} FID = Founder ID 
        access(contract) var creator: {Address : Bool} // {Creators' Address : active/frozen}
        access(contract) var pendingFounder: {Address: UFix64}     // invited Founder
        access(contract) var pendingAdmin  : Address?              // invited Admin

        init(name: String, percentage: UFix64) { // house percentage
            pre { percentage < 1.0 }
            self.aid = AgencyHQ.agencyCounter
            AgencyHQ.agencyCounter = AgencyHQ.agencyCounter + 1
            self.name = name
            self.percentage = percentage
            self.mid            = []
            self.voting         = false
            self.founder        = {}
            self.creator        = {}
            self.pendingFounder = {}
            self.pendingAdmin   = nil
            AgencyHQ.agency.insert(key: self.aid, false)

            log("Agency Created: ".concat(self.aid.toString()))
            emit AgencyCreated(aid: self.aid, name: self.name)
        }

        access(contract) fun setPendingFounder(newFounder: Address, percentage: UFix64 ) {
            self.pendingFounder.insert(key: newFounder, percentage)
        }
        access(contract) fun removePendingFounder(founder: Address) {
            self.pendingFounder.remove(key: founder)
        }
        access(contract) fun setPendingAdmin(newAdmin: Address?) { self.pendingAdmin = newAdmin }
        access(contract) fun setVoting(_ vote: Bool) { self.voting = vote }

        pub fun answerFounderInvite(newFounder: Address, submit: Bool, percentage: UFix64): @Founder? {
            pre {
                self.pendingFounder[newFounder] != nil        : "You got no Founder invite from this Agency."
                self.pendingFounder[newFounder] == percentage : "You have not agreed on the same percentage."
                //Profile.check(newFounder)       : "You can't be an Founder without a Profile. Make one first."
            }
            self.pendingFounder.remove(key:newFounder)
            if !submit { return nil }
            let founder <- create Founder(agency: &self as &Agency, percentage: percentage)!   
            log("Founder: ".concat(newFounder.toString()).concat(" added to Agency") )
            emit NewFounder(agency: self.aid, founder: newFounder)
            return <- founder     
        }  
        
        pub fun answerAdminInvite(newAdmin: Address, submit: Bool): @Admin {
            pre {
                self.pendingAdmin == newAdmin : "You got no Admin invite from this Agency"
                //Profile.check(newAdmin)       : "You can't be an Admin without a Profile. Make one first."
            }
            self.pendingAdmin = nil
            if !submit { panic("Thank you for your time.") }
            let admin <- create Admin()       
            log("Admin: ".concat(newAdmin.toString()).concat(" added to Agency") )
            emit NewAdmin(agency: self.aid, admin: newAdmin)
            return <- admin       
        }
    }
/***********************************************************************/
pub enum CopyrightStatus: UInt8 {
            pub case FRAUD
            pub case CLAIM
            pub case UNVERIFIED
            pub case VERIFIED
            pub case INCLUDED
}
/***********************************************************************/
    pub resource interface Partner {
        pub var aid   : [UInt64] // Agency ID
        pub var status: {UInt64 : Bool} // {AID : (active/frozen) }
    }
/***********************************************************************/
    pub resource Founder: Partner {
        pub  let fid    : UInt64 
        pub  var aid    : [UInt64]        // Agency ID
        pub  var status : {UInt64 : Bool} // {AID : (active/frozen) }
        priv var remove : [Address]
        pub let vote    : @Vote

        init(agency: &Agency, percentage: UFix64) {
            AgencyHQ.founderCounter = AgencyHQ.founderCounter + 1
            self.fid    = AgencyHQ.founderCounter 
            self.aid    = [agency.aid]
            self.status = {}
            self.remove = []
            self.vote <- create Vote(agency: agency)
            agency.founder.insert(key: self.fid, percentage)
            log("Founder: ".concat(self.fid.toString()))
            emit CreatedNewFounder(founder: self.fid)
        }   

        pub fun inviteAdmin(newAdmin: Address, agency: &Agency) {
            pre{
                self.aid.contains(agency.aid) : "Wrong Agency" 
                agency.pendingAdmin == nil    : "Admin invite already pending."
                self.status[agency.aid]!      : "You're no longer a Founder."
                agency.pendingAdmin == nil    : "Admin invite already pending."
            }
            post { agency.pendingAdmin == newAdmin }
            agency.setPendingAdmin(newAdmin: newAdmin)
            log("Sent Admin Invitaion: ".concat(newAdmin.toString()) )
            emit AdminInvited(admin: newAdmin)                        
        }

        pub fun removeAdminInvite(agency: &Agency) {
            pre{
                self.aid.contains(agency.aid) : "Wrong Agency"
                agency.pendingAdmin != nil    : "No pending invitation to Admin."
                self.status[agency.aid]!      : "You're no longer a Founder"
            }
            post { agency.pendingAdmin == nil }
            agency.setPendingAdmin(newAdmin: nil)
            log("Admin Invitaion Removed")
            emit RemovedAdminInvite()                      
        }

        destroy() {
            destroy self.vote
        }
    }
/***********************************************************************/
    pub resource Admin: Partner {
        pub var aid    : [UInt64]       // Agency ID
        pub var status : {UInt64 : Bool} // {AID : (active/frozen) }
        priv var setting: [Bool; 4] // binary conversation 8-bit = 8 setting

        init() {
            self.aid     = []
            self.status  = {}
            self.setting = [false, false, false, false]
        }

        pub fun inviteCreator(creator: Address, agency: &Agency) {  // Admin add a new creator
            pre{
                self.aid.contains(agency.aid)      : "Wrong Agency Key!"
                AgencyHQ.agency[agency.aid] != nil : "You do not belong to this Agency." 
                self.status[agency.aid]!           : "Your accont is Frozen."
                self.setting[0]                    : "Access Denied"
                !agency.creator.containsKey(creator): "Already a Creator."
            }
            post { agency.creator.containsKey(creator) }
            agency.creator.insert(key: creator, false )     
            log("Sent Creator Invation: ".concat(creator.toString()) )
            emit CreatorInvited(creator: creator)   
        }

        pub fun removeCreator(creator: Address, agency: &Agency) {
            pre{
                self.aid.contains(agency.aid)      : "Wrong Agency Key!"
                AgencyHQ.agency[agency.aid] != nil : "You do not belong to this Agency." 
                self.status[agency.aid]!           : "Your accont is Frozen."
                self.setting[1]                    : "Access Denied"
                agency.creator.containsKey(creator): "This is not a valid Creator."
            }
            post { !agency.creator.containsKey(creator) }       
            agency.creator.remove(key: creator)
            log("Removed Creator")
            emit CreatorRemoved(creator: creator)
        }

        pub fun changeCopyright(mid: UInt64, copyright: CopyrightStatus, agency: &Agency) {
            pre{
                self.aid.contains(agency.aid)      : "Wrong Agency Key!"
                AgencyHQ.agency[agency.aid] != nil : "You do not belong to any Agency." 
                self.status[agency.aid]!           : "Your account is Frozen."
                self.setting[2]                    : "Access Denied"
                agency.mid.contains(mid) : "This Metadata ID does not exist in your Agency."
            }
            post { AgencyHQ.copyright[mid] == copyright }
            AgencyHQ.copyright[mid] = copyright
            log("MID: ".concat(mid.toString()) )
            emit ChangedCopyright(metadataID: mid)            
        }

        pub fun changeCreatorStatus(creator: Address, agency: &Agency) {
            pre{
                self.aid.contains(agency.aid)      : "Wrong Agency Key!"
                AgencyHQ.agency[agency.aid] != nil : "You do not belong to any Agency." 
                self.status[agency.aid]!           : "Your account is Frozen."
                self.setting[3]                    : "Access Denied"
                agency.creator.containsKey(creator): "This is not one of your Creators"
            }
            post { before(agency.creator[creator]) != agency.creator[creator] }
            agency.creator[creator] = !agency.creator[creator]!
            log("Creator Status Changed")
            emit ChangeCreatorStatus(creator: creator, status: agency.creator[creator]!)
        }

        pub fun changeAdminSetting(setting: [Bool; 4], agency: &Agency, founder: &Founder) {
            pre{
                self.aid.contains(agency.aid)    : "Wrong Agency!"
                founder.aid.contains(agency.aid) : "You're not a Founder of this Agency!"
                self.status[agency.aid] != nil : "No Admin access is associated with this account."
                self.status[agency.aid]!       : "This Admin account is Frozen."
            }
            //post { self.setting == setting }
            self.setting = setting
            log("Changed Admin Setting")
            emit ChangeAdminSetting() // TODO Consider removing and making Private
        }
    }
/***********************************************************************/
    pub resource Vote {
        pub let born: UFix64
        pub let aid : UInt64
        pub let totalVotes: Int
        pub var voted:  {UInt64 : Bool?} // {fid : (yes, no, null vote) }

        init(agency: &Agency) {
            self.born = getCurrentBlock().timestamp
            self.aid = agency.aid
            self.totalVotes = agency.founder.length
            self.voted  = {}
            log("Vote Created")
            emit VoteInSession(agency: self.aid)
        }

        pub fun generateVote(founder: &Founder, agency: &Agency) {
            pre { founder.aid.contains(self.aid) : "You are not a Founder of this Agency" }
            agency.setVoting(true)
        }

        pub fun myVote(founder: &Founder, vote: Bool?, agency: &Agency ): Bool? {
            pre { founder.aid.contains(self.aid) : "You are not a Founder of this Agency" }
            if ( getCurrentBlock().timestamp > (self.born + 172800.0 as UFix64)) { return self.declareResult(agency: agency) } // Vote is over
            let finished = self.countVotes(founder: founder, vote: vote)
            if(finished) { return self.declareResult(agency: agency) }

            log("Vote: ".concat(agency.aid.toString()))
            emit VoteEntry(agency: agency.aid)
            return nil
        }

        priv fun countVotes(founder: &Founder, vote: Bool?): Bool {
            pre { founder.aid.contains(self.aid) : "You are not a Founder of this Agency" }
            self.voted[founder.fid] = vote
            if self.voted.length == self.totalVotes { return true }

            log("Counting Votes")
            emit CountingVotes()
            return false
        }

        priv fun declareResult(agency: &Agency): Bool {
            var yes = 0.0 as UFix64
            var no  = 0.0 as UFix64
            var null_vote  = agency.percentage           
            for vote in self.voted.keys {
                switch(self.voted[vote]) {
                    case true : yes = yes + agency.founder[vote]!
                    case false: no  = no  + agency.founder[vote]!
                    case nil  : null_vote = null_vote + agency.founder[vote]!
                }
            }
            let no_vote = 1.0 - (yes + no + null_vote)
            assert(no_vote + yes + no + null_vote == 1.0)
            agency.setVoting(false)
            let final_result = (yes > no) ? true : false

            log(final_result ? "Vote Result: PASS" : "Vote Result: FAIL")
            emit VoteResult(result: final_result)
            return final_result
        }

        pub fun inviteFounder(newFounder: Address, percentage: UFix64, agency: &Agency) {
            pre{
                agency.pendingFounder == nil     : "Founder invite already pending."
                !agency.voting                   : "Invitations are not allowed durning a voting session"
            }
            post { agency.pendingFounder[newFounder] == percentage }
            agency.setPendingFounder(newFounder: newFounder, percentage: percentage )
            log("Sent Founder Invitaion: ".concat(newFounder.toString()) )
            emit FounderInvited(founder: newFounder)                        
        }

        pub fun removeFounderInvite(invite: Address, agency: &Agency) {
            pre{
                agency.aid == self.aid       : "Wrong Agency" 
                agency.pendingFounder != nil : "No pending invitation to Founder."
                !agency.voting               : "Removing is not allowed durning a voting session"
            }
            post { agency.pendingFounder == nil } 
            agency.removePendingFounder(founder: invite)
            log("Founder Invitaion Removed")
            emit RemovedFounderInvite()                      
        }

        
    }//End Vote
/***********************************************************************/
    // Functions
    pub fun addAgency(address: Address, name: String, percentage: UFix64, agency: &Agency): @Agency {
        pre { agency.aid == 0 : "Access Denied" }
        let agency <- create Agency(name: name, percentage: percentage)
        AgencyHQ.agency.insert(key: agency.aid, false)

        log("Add Agency: ".concat(agency.aid.toString()))
        emit AddAgency(aid: agency.aid)
        return <- agency
    }

    pub fun removeAgency(aid: UInt64, agency: &Agency) {
        pre {
            agency.aid == 0 : "Access Denied"
            self.agency.containsKey(aid) : "Agency ID number does not exist."
        }
        post { !self.agency.containsKey(aid) }
        AgencyHQ.agency.remove(key: aid)
        log("Remove Agency: ".concat(aid.toString()))
        emit RemoveAgency(aid: aid)
    }
/***********************************************************************/
    init() {
        let founder = 0x0f7025fa05b578e3 as Address
        let percentage = 0.20

        self.agency         = {}
        self.agencyCounter  = 0
        self.founderCounter = 0
        self.copyright      = {}

        // Storage
        self.agencyPublicPath   = /public/DAAM_Agency
        self.agencyStoragePath  = /storage/DAAM_Agency
        self.founderPrivatePath = /private/DAAM_Founder
        self.founderStoragePath = /storage/DAAM_Founder

        // Init Primary Agency & Founder
        let agency <- create Agency(name: "DAAM Agency", percentage: 0.05)
        agency.setPendingFounder(newFounder: founder, percentage: percentage)
        self.account.save(<-agency, to: self.agencyStoragePath)
        self.account.link<&Agency>(self.agencyPublicPath, target: self.agencyStoragePath)

        emit ContractInitialized()
    }
/***********************************************************************/
}// End AgencyHQ
