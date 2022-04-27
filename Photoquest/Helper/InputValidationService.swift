//
//  InputValidationService.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/27/22.
//

import Foundation

struct InputValidationService {
    
    static func validatePassword(password: String?) -> Bool {
        guard let password = password else { return false }

        // Only requirement is for the password to be 12 characters or longer.
        let lengthRegEx = NSPredicate(
            format: "SELF MATCHES %@",
            "^.{12,}$"
        )
        return lengthRegEx.evaluate(with: password)
    }
    
    static func validateEmail(email: String?) -> Bool {
        guard let email = email else { return false }
        /*
         Thanks Maxim Shoustin via StackOverflow
         https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
         */
        let emailRegEx = NSPredicate(
            format: "SELF MATCHES %@",
            "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        )
        return emailRegEx.evaluate(with: email)
    }
}
