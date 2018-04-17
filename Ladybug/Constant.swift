//
//  Constant.swift
//  Ladybug
//
//  Created by Yannis on 23/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

class  Constantes {
    struct ApplicationConstantsAuth {
        static let clientId = "92f55b9c-71f3-437b-ba94-2e231f4136ed"
        static let scopes   = ["https://graph.microsoft.com/Mail.Send", "https://graph.microsoft.com/User.Read", "offline_access"]
    }
    
    enum MSGraphError: Error {
        case nsErrorType(error: NSError)
        
    }
    
    static let screen_Size = UIScreen.main.bounds
    static let TrueBlue = UIColor(colorLiteralRed: 0, green: 0.158456, blue: 0.831596, alpha: 1)
    struct menu {
        static let items = ["Profile", "ELearning", "Etudiants", "Leaderboard", "Deconnexion"]
    }
    struct url_key {
        static let urername = "{user}"
    }
    struct url {
        static let base = "https://intra.epitech.eu"
        static let url_connexion_home = "https://intra.epitech.eu/?format=json"
        static let url_deconnexion =  "https://intra.epitech.eu/logout?format=json"
        static let profile = "https://intra.epitech.eu/user/\(Constantes.url_key.urername)/?format=json"
        static let profile_pic = "https://cdn.local.epitech.eu/userprofil/profilview/{user}.jpg"
        static let notes = "https://intra.epitech.eu/user/\(Constantes.url_key.urername)/notes/?format=json"
        static let student_note_acti = "https://intra.epitech.eu/module/{annee}/{module}/{ville}/{acti}/note/?format=json"
        static let student_binome = "https://intra.epitech.eu/user/{user}/binome/?format=json"
        static let activitie = "https://intra.epitech.eu/module/{year}/{module}/{city}/{acti}/?format=json"
        static let logout = "https://intra.epitech.eu/logout"
        static let office_login = "https://sts.epitech.eu/adfs/ls/?client-request-id=f93caf87-23f7-4a27-8138-c5bc075b5dbb&username={user}&wa=wsignin1.0&wtrealm=urn%3afederation%3aMicrosoftOnline&wctx=estsredirect%3d2%26estsrequest%3drQIIAdNiNtQztFJJNTBNMTE0sdQ1NDMy0TUxMzLXTTRNStQ1NzE3SjS2TDUxTkwqEuISaF9v8_O7srpXo8XRPezRsbtXMapnlJQUFFvp62fmlRQl6qUWZJakJmfopZbqJ5aWZOjnp6VlJqcam5nuYGS8wMj4gpHxFhO_vyNQyghE5BdlVqU-whCZxcyov4mZLTk_Nzc_bxezikWyaaJRcrKFblKqURrQeYZAlmWyua6hiam5hYVJipGpaeINZsYLLIyvWHgMWK04OLgEeCSYFBh-sDAuYgW62_datPXermfOUyotznOp1KefYtWPinT2MTD38A0vcHbzDzc1NC8OSqnKM_MwCXEK9HAtDM41SfNwdy11rLBwtTWxMpzAxriLk1jPAgA1&popupui="
    }
    struct key_userdef {
        static let LOGIN_KEY = "login"
        static let PASS_KEY = "passwd"
        static let CONNECTED_KEY = "connected_log"
        static let CONNEXION_MODE = "connect_mode"
    }
    struct segues {
        static let ENTER_FROM_LOGIN = "enterFromLogin"
        static let PROFILE_TO_NOTES = "profileToNotes"
        static let PROFILE_TO_BINOME = "profileToBinome"
    }
    struct storyboard_id {
        static let PROFILE_VIEW = "PROFILE_VIEW"
        static let LOGIN_VIEW = "LoginViewController"
        static let TROMBI_HOME = "TrombiHomeController"
        static let ELEARNING = "ELearnController"
        static let FILEREADER = "FileReaderMain"
        static let LEADERBORD = "LeaderBoard"
        static let PROJECT_VIEW = "ProjectView"
        static let PROJECT_FULLNOTE_VIEW = "ProjetFullNoteMain"
        static let ACTIVITIE_VIEW = "ActivitieMain"
        static let ACTIVITIE_SESSION = "ActivitieSessionRegistered"
        static let MODULE_VIEW = "ModuleMain"
        static let CONNEXION_ROUTINE = "ConnexionRoutine"
    }
    struct tromby {
        struct url {
            static let schools = "https://intra.epitech.eu/user/filter/location?format=json&active=true"
            static let promos = "https://intra.epitech.eu/user/filter/promo?format=json&location={city}&year={anne}&active=true"
            static let years = "https://intra.epitech.eu/user/filter/year?format=json&location={city}&active=true"
            static let student_list = "https://intra.epitech.eu/user/filter/user?format=json&location={city}&year={year}&active=true&promo={promo}&offset={offset}"
            static let student_search = "https://intra.epitech.eu/complete/user?format=json&contains&search={user}"
        }
    }
    struct elearning {
        struct url {
            static let main = "https://intra.epitech.eu/e-learning/?format=json"
        }
    }
}
