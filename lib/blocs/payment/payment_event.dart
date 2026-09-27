abstract class PaymentAdminEvent {
  const PaymentAdminEvent();
}

/// Load payments for the back office, filtered by status
/// (`awaiting_verification`, `succeeded`, `rejected`, or null = all).
class PaymentsLoadRequested extends PaymentAdminEvent {
  final String? status;
  const PaymentsLoadRequested({this.status});
}

class PaymentApproveRequested extends PaymentAdminEvent {
  final String paymentId;
  const PaymentApproveRequested(this.paymentId);
}

class PaymentRejectRequested extends PaymentAdminEvent {
  final String paymentId;
  final String reason;
  const PaymentRejectRequested(this.paymentId, this.reason);
}
