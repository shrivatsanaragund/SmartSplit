//
//  UserData.swift
//  Smart Split
//
//  Created by Shrivatsa Naragund on 11/20/24.
//

import SwiftUI
import CoreData

class UserData: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var users: [User] = []
}
