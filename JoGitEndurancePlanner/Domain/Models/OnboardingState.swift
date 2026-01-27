//
//  OnboardingState.swift
//  JoGitEndurancePlanner
//
//  Created by AI Assistant on 22.01.2026.
//

import Foundation

/// Manages onboarding completion state with persistent file storage
final class OnboardingStateManager {
    static let shared = OnboardingStateManager()
    
    private let fileManager = FileManager.default
    private let fileName = "onboarding_completed.flag"
    
    private var fileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(fileName)
    }
    
    private init() {
        print("[ONBOARDING_STATE] 📁 File URL: \(fileURL.path)")
    }
    
    /// Check if onboarding has been completed
    var hasCompletedOnboarding: Bool {
        // Check both UserDefaults and file system
        let userDefaultsValue = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let fileExists = fileManager.fileExists(atPath: fileURL.path)
        
        print("[ONBOARDING_STATE] 🔍 Checking completion status:")
        print("[ONBOARDING_STATE] 🔍 UserDefaults: \(userDefaultsValue)")
        print("[ONBOARDING_STATE] 🔍 File exists: \(fileExists)")
        
        // If either is true, consider it completed
        let isCompleted = userDefaultsValue || fileExists
        
        // Sync both storages
        if isCompleted {
            if !userDefaultsValue {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                UserDefaults.standard.synchronize()
            }
            if !fileExists {
                createCompletionFile()
            }
        }
        
        return isCompleted
    }
    
    /// Mark onboarding as completed
    func markAsCompleted() {
        print("[ONBOARDING_STATE] ✅ Marking onboarding as completed")
        
        // Save to UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        let syncSuccess = UserDefaults.standard.synchronize()
        print("[ONBOARDING_STATE] ✅ UserDefaults saved: \(syncSuccess)")
        
        // Save to file system
        createCompletionFile()
        
        // Verify
        let verified = hasCompletedOnboarding
        print("[ONBOARDING_STATE] ✅ Verification: \(verified)")
    }
    
    /// Reset onboarding state (for testing)
    func reset() {
        print("[ONBOARDING_STATE] 🔄 Resetting onboarding state")
        
        // Remove from UserDefaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.synchronize()
        
        // Remove file
        try? fileManager.removeItem(at: fileURL)
        
        print("[ONBOARDING_STATE] 🔄 Reset complete")
    }
    
    // MARK: - Private
    
    private func createCompletionFile() {
        do {
            let data = Date().timeIntervalSince1970.description.data(using: .utf8)
            try data?.write(to: fileURL, options: .atomic)
            print("[ONBOARDING_STATE] 📝 File created successfully at: \(fileURL.path)")
        } catch {
            print("[ONBOARDING_STATE] ❌ Failed to create file: \(error.localizedDescription)")
        }
    }
}

