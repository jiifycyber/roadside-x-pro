enum JobStatus {
  newJob,
  accepted,
  enRoute,
  onSite,
  inProgress,
  completed,
  cancelled,
}

enum SubscriptionStatus { active, pastDue, suspended, cancelled }

enum UserRole { superAdmin, owner, dispatcher, technician }

enum TechnicianStatus { available, busy, offDuty, offline }

typedef JsonMap = Map<String, dynamic>;

class RoadsideJob {
  RoadsideJob({
    required this.id,
    required this.customer,
    required this.phone,
    required this.service,
    required this.location,
    required this.total,
    required this.partsCost,
    required this.status,
    this.latitude,
    this.longitude,
    this.technician = 'Unassigned',
    this.vehicle = '',
    this.notes = '',
    this.paymentMethod = 'Unpaid',
    this.paid = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  final String id;
  String customer;
  String phone;
  String service;
  String location;
  double total;
  double partsCost;
  final DateTime createdAt;
  double? latitude;
  double? longitude;
  String technician;
  JobStatus status;
  String vehicle;
  String notes;
  String paymentMethod;
  bool paid;
  double get profit => total - partsCost;
  bool get hasCoordinates => latitude != null && longitude != null;
  JsonMap toJson() => {
    'id': id,
    'customer': customer,
    'phone': phone,
    'service': service,
    'location': location,
    'total': total,
    'partsCost': partsCost,
    'createdAt': createdAt.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'technician': technician,
    'status': status.name,
    'vehicle': vehicle,
    'notes': notes,
    'paymentMethod': paymentMethod,
    'paid': paid,
  };
  factory RoadsideJob.fromJson(JsonMap j) => RoadsideJob(
    id: j['id'] ?? '',
    customer: j['customer'] ?? '',
    phone: j['phone'] ?? '',
    service: j['service'] ?? '',
    location: j['location'] ?? '',
    total: (j['total'] ?? 0).toDouble(),
    partsCost: (j['partsCost'] ?? 0).toDouble(),
    status: JobStatus.values.byName(j['status'] ?? 'newJob'),
    latitude: (j['latitude'] as num?)?.toDouble(),
    longitude: (j['longitude'] as num?)?.toDouble(),
    technician: j['technician'] ?? 'Unassigned',
    vehicle: j['vehicle'] ?? '',
    notes: j['notes'] ?? '',
    paymentMethod: j['paymentMethod'] ?? 'Unpaid',
    paid: j['paid'] ?? false,
    createdAt: DateTime.tryParse(j['createdAt'] ?? ''),
  );
}

class Customer {
  Customer({
    required this.name,
    required this.phone,
    required this.vehicle,
    this.jobs = 0,
    this.email = '',
    this.notes = '',
  });
  String name;
  String phone;
  String vehicle;
  int jobs;
  String email;
  String notes;
  JsonMap toJson() => {
    'name': name,
    'phone': phone,
    'vehicle': vehicle,
    'jobs': jobs,
    'email': email,
    'notes': notes,
  };
  factory Customer.fromJson(JsonMap j) => Customer(
    name: j['name'] ?? '',
    phone: j['phone'] ?? '',
    vehicle: j['vehicle'] ?? '',
    jobs: j['jobs'] ?? 0,
    email: j['email'] ?? '',
    notes: j['notes'] ?? '',
  );
}

class Technician {
  Technician({
    required this.id,
    required this.name,
    required this.phone,
    required this.area,
    this.status = TechnicianStatus.available,
    this.activeJobs = 0,
    this.latitude,
    this.longitude,
  });
  final String id;
  String name;
  String phone;
  String area;
  TechnicianStatus status;
  int activeJobs;
  double? latitude;
  double? longitude;
  bool get available => status == TechnicianStatus.available;
  JsonMap toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'area': area,
    'status': status.name,
    'activeJobs': activeJobs,
    'latitude': latitude,
    'longitude': longitude,
  };
  factory Technician.fromJson(JsonMap j) => Technician(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    phone: j['phone'] ?? '',
    area: j['area'] ?? '',
    status: TechnicianStatus.values.byName(j['status'] ?? 'available'),
    activeJobs: j['activeJobs'] ?? 0,
    latitude: (j['latitude'] as num?)?.toDouble(),
    longitude: (j['longitude'] as num?)?.toDouble(),
  );
}

class InventoryItem {
  InventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.reorderAt,
    this.unitCost = 0,
  });
  String name;
  String category;
  int quantity;
  int reorderAt;
  double unitCost;
  bool get lowStock => quantity <= reorderAt;
  JsonMap toJson() => {
    'name': name,
    'category': category,
    'quantity': quantity,
    'reorderAt': reorderAt,
    'unitCost': unitCost,
  };
  factory InventoryItem.fromJson(JsonMap j) => InventoryItem(
    name: j['name'] ?? '',
    category: j['category'] ?? '',
    quantity: j['quantity'] ?? 0,
    reorderAt: j['reorderAt'] ?? 0,
    unitCost: (j['unitCost'] ?? 0).toDouble(),
  );
}

class CompanyAccount {
  CompanyAccount({
    required this.name,
    required this.plan,
    required this.monthlyPrice,
    required this.status,
    required this.users,
    required this.nextBilling,
  });
  String name;
  String plan;
  double monthlyPrice;
  SubscriptionStatus status;
  int users;
  DateTime nextBilling;
  JsonMap toJson() => {
    'name': name,
    'plan': plan,
    'monthlyPrice': monthlyPrice,
    'status': status.name,
    'users': users,
    'nextBilling': nextBilling.toIso8601String(),
  };
  factory CompanyAccount.fromJson(JsonMap j) => CompanyAccount(
    name: j['name'] ?? '',
    plan: j['plan'] ?? 'Basic',
    monthlyPrice: (j['monthlyPrice'] ?? 0).toDouble(),
    status: SubscriptionStatus.values.byName(j['status'] ?? 'active'),
    users: j['users'] ?? 1,
    nextBilling: DateTime.tryParse(j['nextBilling'] ?? '') ?? DateTime.now(),
  );
}

class ActivityEntry {
  ActivityEntry(this.action, this.actor, {DateTime? time})
    : time = time ?? DateTime.now();
  final String action;
  final String actor;
  final DateTime time;
  JsonMap toJson() => {
    'action': action,
    'actor': actor,
    'time': time.toIso8601String(),
  };
  factory ActivityEntry.fromJson(JsonMap j) => ActivityEntry(
    j['action'] ?? '',
    j['actor'] ?? '',
    time: DateTime.tryParse(j['time'] ?? ''),
  );
}
