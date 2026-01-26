import CoreData
import Foundation

final class SeedDataLoader {
    private let coreDataStack: CoreDataStackProvider
    
    init(coreDataStack: CoreDataStackProvider = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func loadSeedDataIfNeeded() {
        let hasLoadedKey = "hasSeedDataLoaded_v1"
        
        guard !UserDefaults.standard.bool(forKey: hasLoadedKey) else {
            return
        }
        
        let context = coreDataStack.viewContext
        
        context.performAndWait {
            loadVegetables(context: context)
            loadProteins(context: context)
            loadCarbs(context: context)
            
            do {
                try context.save()
                UserDefaults.standard.set(true, forKey: hasLoadedKey)
            } catch {
                print("Failed to save seed data: \(error)")
            }
        }
    }
    
    private func loadVegetables(context: NSManagedObjectContext) {
        let vegetables = [
            ("Broccoli", "steamed"),
            ("Spinach", "fresh or cooked"),
            ("Carrots", "raw or roasted"),
            ("Bell Peppers", "any color"),
            ("Tomatoes", "fresh"),
            ("Cucumber", "sliced"),
            ("Lettuce", "romaine or mixed"),
            ("Zucchini", "grilled or raw"),
            ("Cauliflower", "roasted"),
            ("Green Beans", "steamed"),
            ("Kale", "massaged or cooked"),
            ("Asparagus", "grilled"),
            ("Brussels Sprouts", "roasted"),
            ("Cabbage", "red or green"),
            ("Celery", "with dip"),
            ("Mushrooms", "sautéed"),
            ("Eggplant", "grilled"),
            ("Beets", "roasted"),
            ("Radishes", "sliced"),
            ("Arugula", "fresh salad"),
            ("Swiss Chard", "sautéed"),
            ("Bok Choy", "stir-fried"),
            ("Snow Peas", "crisp"),
            ("Pumpkin", "roasted"),
            ("Squash", "butternut or acorn"),
            ("Onions", "grilled or raw"),
            ("Leeks", "sautéed"),
            ("Artichoke", "steamed"),
            ("Fennel", "sliced"),
            ("Turnips", "mashed")
        ]
        
        for veg in vegetables {
            let item = CDFoodIngredient(context: context)
            item.identifier = UUID()
            item.titleText = veg.0
            item.descriptionHint = veg.1
            item.categoryRaw = "vegetable"
            item.isUserCreated = false
        }
    }
    
    private func loadProteins(context: NSManagedObjectContext) {
        let proteins = [
            ("Chicken Breast", "grilled or baked"),
            ("Salmon", "wild caught"),
            ("Tuna", "fresh or canned"),
            ("Turkey", "lean cuts"),
            ("Eggs", "boiled or scrambled"),
            ("Greek Yogurt", "plain"),
            ("Tofu", "firm or extra firm"),
            ("Lentils", "cooked"),
            ("Black Beans", "cooked"),
            ("Chickpeas", "roasted or boiled"),
            ("Cottage Cheese", "low fat"),
            ("Shrimp", "grilled"),
            ("Beef", "lean cuts"),
            ("Pork Loin", "trimmed"),
            ("Cod", "baked"),
            ("Tilapia", "grilled"),
            ("Tempeh", "marinated"),
            ("Edamame", "steamed"),
            ("Kidney Beans", "cooked"),
            ("Pinto Beans", "cooked"),
            ("White Beans", "cooked"),
            ("Almonds", "raw or roasted"),
            ("Walnuts", "raw"),
            ("Peanut Butter", "natural"),
            ("Protein Powder", "whey or plant"),
            ("Quinoa", "cooked"),
            ("Hemp Seeds", "raw"),
            ("Chia Seeds", "soaked"),
            ("Pumpkin Seeds", "roasted"),
            ("Turkey Bacon", "cooked")
        ]
        
        for protein in proteins {
            let item = CDFoodIngredient(context: context)
            item.identifier = UUID()
            item.titleText = protein.0
            item.descriptionHint = protein.1
            item.categoryRaw = "protein"
            item.isUserCreated = false
        }
    }
    
    private func loadCarbs(context: NSManagedObjectContext) {
        let carbs = [
            ("Brown Rice", "cooked"),
            ("Quinoa", "cooked"),
            ("Oats", "rolled or steel cut"),
            ("Sweet Potato", "baked or mashed"),
            ("Whole Wheat Bread", "slice"),
            ("Whole Wheat Pasta", "cooked"),
            ("Barley", "cooked"),
            ("Buckwheat", "cooked"),
            ("Wild Rice", "cooked"),
            ("Couscous", "whole wheat"),
            ("Bulgur", "cooked"),
            ("Farro", "cooked"),
            ("Millet", "cooked"),
            ("Rye Bread", "slice"),
            ("Corn", "on cob or kernels"),
            ("Peas", "green"),
            ("White Potato", "baked"),
            ("Sourdough Bread", "slice"),
            ("Rice Cakes", "whole grain"),
            ("Tortilla", "whole wheat"),
            ("Pita Bread", "whole wheat"),
            ("Bagel", "whole grain"),
            ("English Muffin", "whole wheat"),
            ("Crackers", "whole grain"),
            ("Polenta", "cooked"),
            ("Amaranth", "cooked"),
            ("Teff", "cooked"),
            ("Sorghum", "cooked"),
            ("Plantain", "cooked"),
            ("Cassava", "cooked")
        ]
        
        for carb in carbs {
            let item = CDFoodIngredient(context: context)
            item.identifier = UUID()
            item.titleText = carb.0
            item.descriptionHint = carb.1
            item.categoryRaw = "carb"
            item.isUserCreated = false
        }
    }
}

