import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    private let service = Bundle.main.bundleIdentifier ?? "Planvas"
    
    // 불러오기
    func load(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data {
            return String(data:data, encoding: .utf8)
        } else {
            print("Error: \(status)")
            return nil
        }
    }
    
    // 저장하기
    func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let deleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("KeyChain: \(key)저장 완료")
        } else {
            print("KeyChain: \(key)저장 실패, Error:\(status)")
        }
    }
    
    // 삭제하기
    func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("KeyChain 삭제 성공")
        } else {
            print("KeyChain 삭제 실패, Error:\(status)")
        }
    }
}
