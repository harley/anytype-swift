import Foundation
import Combine
import SwiftUI
import ProtobufMessages
import Services
import AnytypeCore

final class AuthService: AuthServiceProtocol {
    
    private enum AuthServiceParsingError: Error {
        case undefinedModel
        case undefinedStatus(status: Anytype_Model_Account.Status)
    }
    
    private let rootPath: String
    private let loginStateService: LoginStateServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let appErrorLoggerConfiguration: AppErrorLoggerConfigurationProtocol
    private let serverConfigurationStorage: ServerConfigurationStorageProtocol
    
    private var subscriptions: [AnyCancellable] = []
    
    init(
        localRepoService: LocalRepoServiceProtocol,
        loginStateService: LoginStateServiceProtocol,
        accountManager: AccountManagerProtocol,
        appErrorLoggerConfiguration: AppErrorLoggerConfigurationProtocol,
        serverConfigurationStorage: ServerConfigurationStorageProtocol
    ) {
        self.rootPath = localRepoService.middlewareRepoPath
        self.loginStateService = loginStateService
        self.accountManager = accountManager
        self.appErrorLoggerConfiguration = appErrorLoggerConfiguration
        self.serverConfigurationStorage = serverConfigurationStorage
    }

    func logout(removeData: Bool, onCompletion: @escaping (Bool) -> ()) {
        Task { @MainActor [weak self] in
            do {
                try await ClientCommands.accountStop(.with {
                    $0.removeData = removeData
                }).invoke()
                await self?.loginStateService.cleanStateAfterLogout()
                onCompletion(true)
            } catch {
                onCompletion(false)
            }
        }
        .cancellable()
        .store(in: &subscriptions)
    }

    func createWallet() async throws -> String {
        let result = try await ClientCommands.walletCreate(.with {
            $0.rootPath = rootPath
        }).invoke()
        return result.mnemonic
    }

    func createAccount(name: String, imagePath: String) async throws -> AccountData {
        do {
            let start = CFAbsoluteTimeGetCurrent()
            
            let response = try await ClientCommands.accountCreate(.with {
                $0.name = name
                $0.avatar = .avatarLocalPath(imagePath)
                $0.icon = Int64(GradientId.random.rawValue)
                $0.disableLocalNetworkSync = true
                if FeatureFlags.selfHosted {
                    $0.networkMode = serverConfigurationStorage.currentConfiguration().middlewareNetworkMode
                    $0.networkCustomConfigFilePath = serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
                }
            }).invoke()
    
            let middleTime = Int(((CFAbsoluteTimeGetCurrent() - start) * 1_000)) // milliseconds
            
            let analyticsId = response.account.info.analyticsID
            AnytypeAnalytics.instance().setUserId(analyticsId)
            AnytypeAnalytics.instance().setNetworkId(response.account.info.networkID)
            AnytypeAnalytics.instance().logAccountCreate(analyticsId: analyticsId, middleTime: middleTime)
            AnytypeAnalytics.instance().logCreateSpace()
            appErrorLoggerConfiguration.setUserId(analyticsId)
            
            let account = response.account.asModel
            
            UserDefaultsConfig.usersId = response.account.id
            
            accountManager.account = account
            
            await loginStateService.setupStateAfterRegistration(account: account)
            return account
        } catch let responseError as Anytype_Rpc.Account.Create.Response.Error {
            throw responseError.asError ?? responseError
        }
    }
    
    func walletRecovery(mnemonic: String) async throws {
        try await ClientCommands.walletRecover(.with {
            $0.rootPath = rootPath
            $0.mnemonic = mnemonic
        }).invoke()
    }

    func accountRecover(onCompletion: @escaping (AuthServiceError?) -> ()) {
        Task { @MainActor [weak self] in
            do {
                _ = try await ClientCommands.accountRecover().invoke()
                self?.loginStateService.setupStateAfterAuth()
                return onCompletion(nil)
            } catch {
                let code = (error as? Anytype_Rpc.Account.Recover.Response.Error)?.code ?? .null
                return onCompletion(AuthServiceError.recoverAccountError(code: code))
            }
        }
        .cancellable()
        .store(in: &subscriptions)
    }
    
    func accountRecover() async throws {
        do {
            try await ClientCommands.accountRecover().invoke()
            loginStateService.setupStateAfterAuth()
        } catch {
            let code = (error as? Anytype_Rpc.Account.Recover.Response.Error)?.code ?? .null
            throw AuthServiceError.recoverAccountError(code: code)
        }
    }
    
    func selectAccount(id: String) async throws -> AccountStatus {
        do {
            let response = try await ClientCommands.accountSelect(.with {
                $0.id = id
                $0.rootPath = rootPath
                $0.disableLocalNetworkSync = true
                if FeatureFlags.selfHosted {
                    $0.networkMode = serverConfigurationStorage.currentConfiguration().middlewareNetworkMode
                    $0.networkCustomConfigFilePath = serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
                }
            }).invoke()
            
            let analyticsId = response.account.info.analyticsID
            AnytypeAnalytics.instance().setUserId(analyticsId)
            AnytypeAnalytics.instance().setNetworkId(response.account.info.networkID)
            AnytypeAnalytics.instance().logAccountOpen(analyticsId: analyticsId)
            appErrorLoggerConfiguration.setUserId(analyticsId)
            
            guard let status = response.account.status.asModel else {
                throw AuthServiceParsingError.undefinedStatus(status: response.account.status)
            }
            
            switch status {
            case .active, .pendingDeletion:
                await setupAccountData(response.account.asModel)
            case .deleted:
                await loginStateService.cleanStateAfterLogout()
            }
            
            return status
        } catch let responseError as Anytype_Rpc.Account.Select.Response.Error {
            throw responseError.asError ?? responseError
        }
    }
    
    private func setupAccountData(_ account: AccountData) async {
        UserDefaultsConfig.usersId = account.id
        accountManager.account = account
        await loginStateService.setupStateAfterLoginOrAuth(account: accountManager.account)
    }
    
    func deleteAccount() async throws -> AccountStatus {
        let result = try await ClientCommands.accountDelete().invoke()
        guard let model = result.status.asModel else {
            throw AuthServiceParsingError.undefinedModel
        }
        
        return model
    }
    
    func restoreAccount() async throws -> AccountStatus {
        let result = try await ClientCommands.accountRevertDeletion().invoke()
        guard let model = result.status.asModel else {
            throw AuthServiceParsingError.undefinedModel
        }
        return model
    }
    
    func mnemonicByEntropy(_ entropy: String) async throws -> String {
        do {
            let result = try await ClientCommands.walletConvert(.with {
                $0.entropy = entropy
            }).invoke()
            return result.mnemonic
        } catch {
            throw AuthServiceError.selectAccountError
        }
    }
}
