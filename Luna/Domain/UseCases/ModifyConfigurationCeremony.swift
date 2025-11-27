import Foundation

class ModifyConfigurationCeremony {
    private let configArchive: ConfigurationArchiveProtocol
    
    init(configArchive: ConfigurationArchiveProtocol) {
        self.configArchive = configArchive
    }
    
    func transformConfiguration(_ prism: ConfigurationPrism) {
        configArchive.modifyConfiguration(prism)
    }
    
    func retrieveCurrentConfiguration() -> ConfigurationPrism {
        configArchive.retrieveConfiguration()
    }
}

