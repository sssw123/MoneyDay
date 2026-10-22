abstract interface class SessionStore {
  String? read();
  void write(String? value);
}

class MemorySessionStore implements SessionStore {
  String? value;
  @override
  String? read() => value;
  @override
  void write(String? value) => this.value = value;
}

SessionStore createSessionStore() => MemorySessionStore();
