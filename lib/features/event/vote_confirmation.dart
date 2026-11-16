/// A server read, not a locally cached write, is the source of truth for a vote.
enum VoteCheckStatus { recorded, notFound, unknown }

class VoteCheck {
  final VoteCheckStatus status;
  final String? option;
  const VoteCheck._(this.status, this.option);
  const VoteCheck.recorded(String option)
    : this._(VoteCheckStatus.recorded, option);
  const VoteCheck.notFound() : this._(VoteCheckStatus.notFound, null);
  const VoteCheck.unknown() : this._(VoteCheckStatus.unknown, null);
}

/// Even if the submission throws, it may already have committed on the server.
/// Re-read the immutable UID/round ballot; never retry a write automatically.
class VoteConfirmation {
  static Future<VoteCheck> check(
    Future<String?> Function() readFromServer,
  ) async {
    try {
      final option = await readFromServer().timeout(
        const Duration(seconds: 12),
      );
      if (option == null) return const VoteCheck.notFound();
      if (!const ['A', 'B', 'C'].contains(option)) {
        return const VoteCheck.unknown();
      }
      return VoteCheck.recorded(option);
    } catch (_) {
      return const VoteCheck.unknown();
    }
  }

  static Future<VoteCheck> submit({
    required Future<void> Function() send,
    required Future<String?> Function() readFromServer,
  }) async {
    try {
      await send();
    } catch (_) {
      // The response could be lost after a successful commit. Check rather
      // than reporting failure or retrying a non-idempotent operation.
    }
    return check(readFromServer);
  }
}
