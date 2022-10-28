// Based on verses Profile. Needed Profilw without 
import MetadataViews from 0xf8d6e0586b0a20c7

pub contract DAAM_Profile {
    // Structs
    // User
    pub struct User {
        pub let name: String
        pub var email: String?
        pub var about: String?
        pub var description: String?
        pub var web: [MetadataViews.ExternalURL]
        pub var social : {String: String}
        pub var avatar: MetadataViews.File?
        pub var heroImage: MetadataViews.File?
        pub var notes: {String: String}  // {Types of Notes : Note}

    
        priv fun verifyEmail(_ email: String?): Bool {
            if email == nil { return true } // no email entered, pass
            // check email format here TODO
            return true // TODO return false here
        }

        init(name: String, email: String?, about: String?, description: String?, web: MetadataViews.ExternalURl?, social: {String:String}?, avatar: MetadataViews.File?,
            heroImage: MetadataViews.File?, notes: {String:String}? ) {
            pre { self.verifyEmail(email) : "Invalid Format" }
            self.name   = name
            self.email  = email
            self.about  = about
            self.description = description          
            self.web    = (web != nil) ? web! : []
            self.social = (social != nil) ? social! : {}
            self.avatar = avatar
            self.heroImage   = heroImage
            self.notes  = (notes != nil) ? notes! : {}
        }
        // Set Functions
        pub fun setEmail(_ email: String?) { self.email = email }
        pub fun setAbout(_ about: String?) { self.about = about }
        pub fun setDesc(_ desc: String?)   { self.description = desc }
        pub fun setAvatar(_ avatar: MetadataViews.File?)  { self.avatar = avatar }
        pub fun setHeroImage(_ hero: MetadataViews.File?) { self.heroImage = hero }

        // Add Functions
        pub fun addWeb(_ web: MetadataViews.ExternalURL) {
            pre { !self.web.contains(web) : web.url.concat(" have already been saved.") }
            self.web.append(web)
        }

        pub fun addSocial(_ social: {String:String}) {
            for s in social.keys {
                self.social[s] = social[s]
            }
        }

        pub fun addNotes(_ web: {String:String}) {
            for w in web.keys {
                self.web[w] = web[w]
            }
        }

        // Remove Functions
        pub fun removeSocial(_ social: String) {
            pre { self.social.containsKey(social) : social.concat(" doesn not exist.") }
            self.social.remove(key:social)
        }

        pub fun removeNotes(_ note: String) {
            pre { self.notes.containsKey(note) : note.concat(" doesn not exist.") }
            self.notes.remove(key:note)
        }

        pub fun getProfile(): UserHandler {
            return UserHandler(&self! as &User)
        }
    }

    // UserHandler
    pub struct UserHandler {
        pub let name: String
        pub let email: String?
        pub let about: String?
        pub let description: String?
        pub let web: [MetadataViews.ExternalURL]
        pub let social : {String: String}
        pub let avatar: MetadataViews.File?
        pub let heroImage: MetadataViews.File?
        pub let notes: {String: String}

        init(_ user: &User) {
            pre { user != nil }
            self.name = user.name
            self.email = user.email
            self.about = user.about
            self.description = user.description
            self.web = user.web
            self.social = user.social
            self.avatar = user.avatar
            self.heroImage = user.heroImage
            self.notes = user.notes
        }
    }


}