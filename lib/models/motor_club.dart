enum IntegrationMode { api, webhook, email, csv, manual }

enum ConnectorStatus { disconnected, testing, connected, attention }

enum PartnerCategory {
  motorClub,
  insurance,
  fleet,
  dealership,
  rental,
  platform,
}

enum ClubDispatchStatus {
  incoming,
  accepted,
  declined,
  assigned,
  enRoute,
  onSite,
  completed,
  cancelled,
  invoiced,
  paid,
}

typedef MotorJson = Map<String, dynamic>;

class PartnerConnector {
  PartnerConnector({
    required this.id,
    required this.name,
    required this.category,
    this.mode = IntegrationMode.manual,
    this.status = ConnectorStatus.disconnected,
    this.providerId = '',
    this.endpoint = '',
    this.apiKeyLabel = '',
    this.lastSync,
    this.notes = '',
  });

  final String id;
  String name;
  PartnerCategory category;
  IntegrationMode mode;
  ConnectorStatus status;
  String providerId;
  String endpoint;
  String apiKeyLabel;
  DateTime? lastSync;
  String notes;

  MotorJson toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'mode': mode.name,
    'status': status.name,
    'providerId': providerId,
    'endpoint': endpoint,
    'apiKeyLabel': apiKeyLabel,
    'lastSync': lastSync?.toIso8601String(),
    'notes': notes,
  };

  factory PartnerConnector.fromJson(MotorJson j) => PartnerConnector(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    category: PartnerCategory.values.byName(j['category'] ?? 'motorClub'),
    mode: IntegrationMode.values.byName(j['mode'] ?? 'manual'),
    status: ConnectorStatus.values.byName(j['status'] ?? 'disconnected'),
    providerId: j['providerId'] ?? '',
    endpoint: j['endpoint'] ?? '',
    apiKeyLabel: j['apiKeyLabel'] ?? '',
    lastSync: DateTime.tryParse(j['lastSync'] ?? ''),
    notes: j['notes'] ?? '',
  );
}

class ClubDispatch {
  ClubDispatch({
    required this.id,
    required this.partner,
    required this.referenceNumber,
    required this.customer,
    required this.phone,
    required this.vehicle,
    required this.service,
    required this.pickupAddress,
    this.destinationAddress = '',
    this.purchaseOrder = '',
    this.authorizedAmount = 0,
    this.authorizedMiles = 0,
    this.status = ClubDispatchStatus.incoming,
    this.technician = 'Unassigned',
    this.etaMinutes,
    this.notes = '',
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  final String id;
  String partner;
  String referenceNumber;
  String purchaseOrder;
  String customer;
  String phone;
  String vehicle;
  String service;
  String pickupAddress;
  String destinationAddress;
  double authorizedAmount;
  double authorizedMiles;
  ClubDispatchStatus status;
  String technician;
  int? etaMinutes;
  String notes;
  final DateTime receivedAt;

  MotorJson toJson() => {
    'id': id,
    'partner': partner,
    'referenceNumber': referenceNumber,
    'purchaseOrder': purchaseOrder,
    'customer': customer,
    'phone': phone,
    'vehicle': vehicle,
    'service': service,
    'pickupAddress': pickupAddress,
    'destinationAddress': destinationAddress,
    'authorizedAmount': authorizedAmount,
    'authorizedMiles': authorizedMiles,
    'status': status.name,
    'technician': technician,
    'etaMinutes': etaMinutes,
    'notes': notes,
    'receivedAt': receivedAt.toIso8601String(),
  };

  factory ClubDispatch.fromJson(MotorJson j) => ClubDispatch(
    id: j['id'] ?? '',
    partner: j['partner'] ?? '',
    referenceNumber: j['referenceNumber'] ?? '',
    purchaseOrder: j['purchaseOrder'] ?? '',
    customer: j['customer'] ?? '',
    phone: j['phone'] ?? '',
    vehicle: j['vehicle'] ?? '',
    service: j['service'] ?? '',
    pickupAddress: j['pickupAddress'] ?? '',
    destinationAddress: j['destinationAddress'] ?? '',
    authorizedAmount: (j['authorizedAmount'] ?? 0).toDouble(),
    authorizedMiles: (j['authorizedMiles'] ?? 0).toDouble(),
    status: ClubDispatchStatus.values.byName(j['status'] ?? 'incoming'),
    technician: j['technician'] ?? 'Unassigned',
    etaMinutes: j['etaMinutes'],
    notes: j['notes'] ?? '',
    receivedAt: DateTime.tryParse(j['receivedAt'] ?? ''),
  );
}

String connectorStatusLabel(ConnectorStatus status) {
  switch (status) {
    case ConnectorStatus.disconnected:
      return 'Disconnected';
    case ConnectorStatus.testing:
      return 'Testing';
    case ConnectorStatus.connected:
      return 'Connected';
    case ConnectorStatus.attention:
      return 'Needs Attention';
  }
}

String clubDispatchStatusLabel(ClubDispatchStatus status) {
  switch (status) {
    case ClubDispatchStatus.incoming:
      return 'Incoming';
    case ClubDispatchStatus.accepted:
      return 'Accepted';
    case ClubDispatchStatus.declined:
      return 'Declined';
    case ClubDispatchStatus.assigned:
      return 'Assigned';
    case ClubDispatchStatus.enRoute:
      return 'En Route';
    case ClubDispatchStatus.onSite:
      return 'On Site';
    case ClubDispatchStatus.completed:
      return 'Completed';
    case ClubDispatchStatus.cancelled:
      return 'Cancelled';
    case ClubDispatchStatus.invoiced:
      return 'Invoiced';
    case ClubDispatchStatus.paid:
      return 'Paid';
  }
}
