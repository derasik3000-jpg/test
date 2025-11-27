import Foundation

protocol ConfigurationArchiveProtocol {
    func retrieveConfiguration() -> ConfigurationPrism
    func modifyConfiguration(_ prism: ConfigurationPrism)
}

