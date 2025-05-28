//
//  AppIntent.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/27.
//

import Foundation
import Intents

class AppIntent {
    
    class func allowSiri() {
        INPreferences.requestSiriAuthorization { status in
            switch status {
            case .notDetermined, .restricted, .denied:
                print("Siri error.")
            case .authorized:
                print("Siri ok.")
            }
        }
    }
    
    class func archive() {
        let intent = CreateAARIntent()
        intent.suggestedInvocationPhrase = "Create AAR"
        intent.inputPath = []
        
        let interaction = INInteraction(intent: intent, response: nil)
        
        interaction.donate { error in
            if let error = error as NSError? {
                print("Interaction donation failed: \(error.description)")
            } else {
                print("Successfully donated interaction.")
            }
        }
    }
}
