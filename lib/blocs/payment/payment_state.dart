import '../../models/payment.dart';

class PaymentAdminState {
  final List<StaffPayment> payments;
  final bool loading;
  final String? error;

  /// The status filter currently applied (null = all).
  final String? filter;

  /// Bumped after every successful approve/reject so the screen can refresh the
  /// bookings list (an approval flips the booking to paid/approved).
  final int actionSeq;

  const PaymentAdminState({
    this.payments = const [],
    this.loading = false,
    this.error,
    this.filter = 'awaiting_verification',
    this.actionSeq = 0,
  });

  // Distinguishes "filter not passed" (keep current) from "filter set to null"
  // (the All view). A plain `filter ?? this.filter` cannot express the latter.
  static const Object _keep = Object();

  PaymentAdminState copyWith({
    List<StaffPayment>? payments,
    bool? loading,
    String? error,
    Object? filter = _keep,
    int? actionSeq,
  }) {
    return PaymentAdminState(
      payments: payments ?? this.payments,
      loading: loading ?? this.loading,
      error: error,
      filter: identical(filter, _keep) ? this.filter : filter as String?,
      actionSeq: actionSeq ?? this.actionSeq,
    );
  }
}
