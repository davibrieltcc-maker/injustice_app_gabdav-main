abstract interface class ISessionStorage {
  Future<String?> getSelectedAccountId();
  Future<void> saveSelectedAccountId(String id);
  Future<void> clearSelectedAccountId();
}
