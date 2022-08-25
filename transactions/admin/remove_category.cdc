// remove_category.cdc
// Remove a new category to contract Category

import Categories from 0xa4ad5ea5c0bd2fba
import DAAM_V22.V22       from 0xa4ad5ea5c0bd2fba

transaction(category: String) {
    let category: String
    let admin   : &DAAM_V22.Admin

    prepare(admin: AuthAccount) {
        self.category = category
<<<<<<< HEAD
        self.admin    = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.V22.adminStoragePath)!
=======
        self.admin    = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
    }

    pre { Categories.getCategories().contains(category) }

    execute {
        self.admin.removeCategory(name: self.category)
        log("Category: ".concat(self.category).concat(" removed."))
    }
}
