//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation

public let apiKeyString = "s2kj4dq33rpy"
public let applicationGroupIdentifier = "group.io.getstream.iOS.ChatDemoApp"
public let currentUserIdRegisteredForPush = "currentUserIdRegisteredForPush"

public struct UserCredentials {
    let id: String
    let name: String
    let avatarURL: URL
    let token: String
    let birthLand: String
}

public extension UserCredentials {
    static func builtInUsersByID(id: String) -> UserCredentials? {
        builtInUsers.filter { $0.id == id }.first
    }

    static let builtInUsers: [UserCredentials] = [
        (
            "luke_skywalker",
            "Luke Skywalker",
            "https://vignette.wikia.nocookie.net/starwars/images/2/20/LukeTLJ.jpg",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibHVrZV9za3l3YWxrZXIiLCJleHAiOjE2NDAyODU4NDV9.P6qfvztaapVJV4gWorARWtk_FSZD5eS6nhvZz5P_-m0",
            "Tatooine"
        ),
        (
            "leia_organa",
            "Leia Organa",
            "https://vignette.wikia.nocookie.net/starwars/images/f/fc/Leia_Organa_TLJ.png",
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibGVpYV9vcmdhbmEiLCJleHAiOjE2NDAyODU3ODJ9.XRE8AGpWbbjArKvjT2xOFHf91Wuu8hy2Vi4PH1Zqwig",
            "Polis Massa"
        )

    ].map {
        UserCredentials(id: $0.0, name: $0.1, avatarURL: URL(string: $0.2)!, token: $0.3, birthLand: $0.4)
    }
}
