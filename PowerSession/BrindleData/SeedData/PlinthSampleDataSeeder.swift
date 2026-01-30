import Foundation
import CoreData

public final class PlinthSampleDataSeeder {
    
    public static func quirkSeedIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<SternReplacementEntity> = SternReplacementEntity.fetchRequest()
        request.fetchLimit = 1
        
        if (try? context.fetch(request).count) ?? 0 > 0 {
            return
        }
        
        vexSeedReplacements(context: context)
        
        do {
            try context.save()
        } catch {
            print("Failed to seed data: \(error)")
        }
    }
    
    private static func vexSeedReplacements(context: NSManagedObjectContext) {
        let replacements: [(String, String, QuellEquivType, SternDurationBand, Set<VexGoalTag>, BrindleDifficulty, [(String, String?, Set<PlinthEquipment>, BrindleDifficulty)])] = [
            (
                "Stadium Intervals",
                "Treadmill 8×2 min (R1 min)",
                .interval(reps: 8, workSec: 120, restSec: 60),
                .medium,
                [.end, .pow],
                .medium,
                [
                    ("Treadmill 8×2 min intervals", "R1 min easy", [.treadmill], .medium),
                    ("Jump rope 6×3 min rounds", "R60 sec", [.rope], .medium),
                    ("EMOM 20 min burpees", "5 burpees + 30s walk", [.none], .hard)
                ]
            ),
            (
                "Long Park Run",
                "Treadmill 40 min Z2",
                .continuous(minutes: 40, zone: "Z2"),
                .long,
                [.end],
                .light,
                [
                    ("Treadmill 40 min Z2", "Keep steady pace", [.treadmill], .light),
                    ("Bike trainer 45 min Z2", "Indoor cycling", [.turbo], .light),
                    ("Stairs 30 min steady", "Climb at moderate pace", [.stairs], .medium)
                ]
            ),
            (
                "Hill Sprints Outdoors",
                "Stairs 10× sprints",
                .interval(reps: 10, workSec: 30, restSec: 90),
                .short,
                [.pow, .str],
                .hard,
                [
                    ("Building stairs 10× sprints", "Sprint up, walk down", [.stairs], .hard),
                    ("Stepper 15 min high intensity", "Max effort intervals", [.stepper], .hard),
                    ("Jump squats 10×8 reps", "R90 sec", [.none], .hard)
                ]
            ),
            (
                "Easy Recovery Walk",
                "Treadmill 25 min walk",
                .continuous(minutes: 25, zone: "Easy"),
                .medium,
                [.rec, .mob],
                .light,
                [
                    ("Treadmill 25 min walk", "Low incline, easy pace", [.treadmill], .light),
                    ("Mobility flow 20 min", "Full body stretches", [.mat], .light),
                    ("Light stairs 20 min", "Slow steady climb", [.stairs], .light)
                ]
            ),
            (
                "Track 400m Repeats",
                "Treadmill 6×400m (R2 min)",
                .interval(reps: 6, workSec: 90, restSec: 120),
                .medium,
                [.end, .pow],
                .hard,
                [
                    ("Treadmill 6×90 sec fast", "R2 min jog", [.treadmill], .hard),
                    ("Jump rope 8×2 min rounds", "R90 sec", [.rope], .hard),
                    ("Burpee+jump 6×15 reps", "R2 min", [.none], .hard)
                ]
            ),
            (
                "Tempo Run 5K",
                "Treadmill 30 min tempo",
                .continuous(minutes: 30, zone: "Tempo"),
                .medium,
                [.end, .str],
                .medium,
                [
                    ("Treadmill 30 min tempo", "Comfortably hard pace", [.treadmill], .medium),
                    ("Bike trainer 35 min tempo", "Z3-Z4 effort", [.turbo], .medium),
                    ("Stairs 25 min continuous", "Moderate push", [.stairs], .medium)
                ]
            ),
            (
                "Bike Commute Ride",
                "Bike trainer 50 min Z2",
                .continuous(minutes: 50, zone: "Z2"),
                .long,
                [.end],
                .light,
                [
                    ("Bike trainer 50 min Z2", "Keep cadence 80-90", [.turbo], .light),
                    ("Treadmill 45 min Z2", "Easy conversational pace", [.treadmill], .light),
                    ("Stepper 40 min steady", "Moderate resistance", [.stepper], .medium)
                ]
            ),
            (
                "Strength Circuit Outdoors",
                "Bodyweight circuit 30 min",
                .continuous(minutes: 30, zone: nil),
                .medium,
                [.str, .mix],
                .medium,
                [
                    ("Bodyweight circuit 30 min", "Push-ups, squats, planks", [.mat], .medium),
                    ("Dumbbell circuit 25 min", "If weights available", [.mat], .medium),
                    ("Stair climbs + pushups", "10 rounds combo", [.stairs], .hard)
                ]
            ),
            (
                "Speed Drills Track",
                "Hallway sprints 12×20m",
                .interval(reps: 12, workSec: 10, restSec: 50),
                .short,
                [.pow, .skl],
                .hard,
                [
                    ("Hallway sprints 12×20m", "Max effort, R50s", [.none], .hard),
                    ("Jump rope speed 10×30s", "R60s rest", [.rope], .hard),
                    ("High knees 10×30s", "Explosive reps", [.none], .medium)
                ]
            ),
            (
                "Yoga in Park",
                "Yoga flow 40 min",
                .continuous(minutes: 40, zone: nil),
                .long,
                [.mob, .rec],
                .light,
                [
                    ("Yoga mat flow 40 min", "Full body stretching", [.mat], .light),
                    ("Mobility routine 35 min", "Hips, shoulders, spine", [.mat], .light),
                    ("Gentle stretching 30 min", "Relaxing pace", [.mat], .light)
                ]
            )
        ]
        
        for (aTitle, bTitle, equiv, band, tags, difficulty, variants) in replacements {
            let replEntity = SternReplacementEntity(context: context)
            replEntity.fizzId = UUID()
            replEntity.tarnATitle = aTitle
            replEntity.tarnBTitle = bTitle
            replEntity.plinthBand = Int16(band.rawValue)
            replEntity.wharfTagsBits = tags.fizzCombinedBits
            replEntity.brindleDifficulty = Int16(difficulty.rawValue)
            replEntity.tarnIsFavorite = false
            replEntity.plinthCreatedAt = Date()
            replEntity.plinthUpdatedAt = Date()
            
            switch equiv {
            case .continuous(let minutes, let zone):
                replEntity.quellEquivType = 0
                replEntity.quellMinutes = Int16(minutes)
                replEntity.quellZone = zone
            case .interval(let reps, let workSec, let restSec):
                replEntity.quellEquivType = 1
                replEntity.quellReps = Int16(reps)
                replEntity.quellWorkSec = Int16(workSec)
                replEntity.quellRestSec = Int16(restSec ?? 0)
            }
            
            var allEquip = Set<PlinthEquipment>()
            for (index, (varTitle, varDetail, equips, varDiff)) in variants.enumerated() {
                let varEntity = MurkyVariantEntity(context: context)
                varEntity.fizzId = UUID()
                varEntity.tarnTitle = varTitle
                varEntity.tarnDetail = varDetail
                varEntity.wharfEquipBits = equips.fizzCombinedBits
                varEntity.brindleDifficulty = Int16(varDiff.rawValue)
                varEntity.plinthOrder = Int16(index)
                varEntity.quirkReplacement = replEntity
                
                allEquip.formUnion(equips)
            }
            
            replEntity.wharfEquipBits = allEquip.fizzCombinedBits
        }
    }
}

