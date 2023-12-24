
import Foundation
import JWTDecode

final class CurrentUserInfo {
    
    private enum UserInfo: String {
        case userName
        case accessToken
        case refreshToken
        case userId
        case roleName
        case roleId
        case usedId
        case email
        case isactive
        case phone
        case skip
        case location
        case language
        case latitude
        case longitude
        case firstName
        case lastName
        case profileUrl
        case masterData
    }
    
    
    static var userName: String! {
        get {
            return UserDefaults.standard.string(forKey: UserInfo.userName.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = UserInfo.userName.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var firstName: String! {
        get {
            return UserDefaults.standard.string(forKey: UserInfo.firstName.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = UserInfo.firstName.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }

    static var lastName: String! {
        get {
            return UserDefaults.standard.string(forKey: UserInfo.lastName.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = UserInfo.lastName.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }

    static var latitude: String! {
        get {
            return UserDefaults.standard.string(forKey: UserInfo.latitude.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = UserInfo.latitude.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var longitude: String! {
        get {
            return UserDefaults.standard.string(forKey: UserInfo.longitude.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = UserInfo.longitude.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var isactive: String! {
           get {
               return UserDefaults.standard.string(forKey: UserInfo.isactive.rawValue)
           }
           set {
               let defaults = UserDefaults.standard
               let key = UserInfo.isactive.rawValue
               
               if let name = newValue {
                   defaults.set(name, forKey: key)
               } else {
                   defaults.removeObject(forKey: key)
               }
           }
       }
    
    static var userdId: String! {
           get {
               return UserDefaults.standard.string(forKey: UserInfo.usedId.rawValue)
           }
           set {
               let defaults = UserDefaults.standard
               let key = UserInfo.usedId.rawValue
               
               if let name = newValue {
                   defaults.set(name, forKey: key)
               } else {
                   defaults.removeObject(forKey: key)
               }
           }
       }
    
    static var roleId: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.roleId.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.roleId.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }
    
    static var profileUrl: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.profileUrl.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.profileUrl.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }
    
    static var accessToken: String! {
        get {
            return UserDefaults.standard.string(forKey: UserInfo.accessToken.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = UserInfo.accessToken.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var refreshToken: String! {
        get {
            return UserDefaults.standard.string(forKey: UserInfo.refreshToken.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = UserInfo.refreshToken.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var expired: Bool {
        get {
            if let token  = CurrentUserInfo.accessToken{
                do {
                    if let jwt = try decode(jwt: token ) as JWT?{
                        if jwt.expired {
                            return true
                        }
                        else{
                            return false
                        }
                    }
                    else{
                        return false
                    }
                } catch
                {
                    return false
                }
            }
            return false
        }
    }
    
    static var userId: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.userId.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.userId.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }
    
    static var isSkip: String! {
            get {
                return UserDefaults.standard.string(forKey: UserInfo.skip.rawValue)
            }
            set {
                let defaults = UserDefaults.standard
                let key = UserInfo.skip.rawValue
                
                if let name = newValue {
                    defaults.set(name, forKey: key)
                } else {
                    defaults.removeObject(forKey: key)
                }
            }
        }
    
    static var roleName: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.roleName.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.roleName.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }
    
    static var phone: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.phone.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.phone.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }
    
    static var email: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.email.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.email.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }
    
    static var location: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.location.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.location.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }
    
    static var language: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.masterData.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.language.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }

    static var masterData: String! {
          get {
              return UserDefaults.standard.string(forKey: UserInfo.masterData.rawValue)
          }
          set {
              let defaults = UserDefaults.standard
              let key = UserInfo.masterData.rawValue
              
              if let name = newValue {
                  defaults.set(name, forKey: key)
              } else {
                  defaults.removeObject(forKey: key)
              }
          }
      }
}
