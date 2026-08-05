import 'package:flutter/foundation.dart';
import '../models/entities.dart';
import '../models/motor_club.dart';
import '../services/local_storage_service.dart';

class AppState extends ChangeNotifier {
  AppState._();
  final LocalStorageService _storage = LocalStorageService();
  bool initialized = false;

  static Future<AppState> create() async {
    final state = AppState._();
    final data = await state._storage.load();
    if (data == null) {
      state._seed();
      await state._persist();
    } else {
      state._restore(data);
    }
    state.initialized = true;
    return state;
  }

  void _seed() {
    jobs.addAll([
      RoadsideJob(
        id: 'JR-4101',
        customer: 'Grant Pace',
        phone: '205-555-0188',
        service: 'Battery Replacement',
        location: 'Hoover, AL',
        total: 367.40,
        partsCost: 209,
        status: JobStatus.completed,
        technician: 'Carlos Rivera',
        latitude: 33.4054,
        longitude: -86.8114,
      ),
      RoadsideJob(
        id: 'JR-4102',
        customer: 'Jim Gentry',
        phone: '205-399-5669',
        service: 'Tire Change',
        location: 'Birmingham, AL',
        total: 448,
        partsCost: 323,
        status: JobStatus.enRoute,
        technician: 'Brandon Hall',
        latitude: 33.5186,
        longitude: -86.8104,
      ),
      RoadsideJob(
        id: 'JR-4103',
        customer: 'Angela Moore',
        phone: '205-555-0164',
        service: 'Vehicle Lockout',
        location: 'Bessemer, AL',
        total: 137.50,
        partsCost: 0,
        status: JobStatus.newJob,
        latitude: 33.4018,
        longitude: -86.9544,
      ),
    ]);
    customers.addAll([
      Customer(
        name: 'Grant Pace',
        phone: '205-555-0188',
        vehicle: '2018 Nissan Altima',
        jobs: 2,
      ),
      Customer(
        name: 'Jim Gentry',
        phone: '205-399-5669',
        vehicle: '2021 Grand Design',
        jobs: 1,
      ),
      Customer(
        name: 'Angela Moore',
        phone: '205-555-0164',
        vehicle: '2020 Toyota Camry',
        jobs: 3,
      ),
    ]);
    technicians.addAll([
      Technician(
        id: 'TECH-001',
        name: 'Carlos Rivera',
        phone: '205-555-0111',
        area: 'Birmingham',
      ),
      Technician(
        id: 'TECH-002',
        name: 'Brandon Hall',
        phone: '205-555-0112',
        area: 'Hoover',
        status: TechnicianStatus.busy,
      ),
      Technician(
        id: 'TECH-003',
        name: 'Luis Martinez',
        phone: '205-555-0113',
        area: 'Bessemer',
        status: TechnicianStatus.offDuty,
      ),
    ]);
    inventory.addAll([
      InventoryItem(
        name: 'H6 Battery',
        category: 'Battery',
        quantity: 3,
        reorderAt: 2,
      ),
      InventoryItem(
        name: '225/60R16 Tire',
        category: 'Tire',
        quantity: 2,
        reorderAt: 2,
      ),
      InventoryItem(
        name: 'Fuel Can',
        category: 'Equipment',
        quantity: 5,
        reorderAt: 1,
      ),
      InventoryItem(
        name: 'Lockout Kit',
        category: 'Equipment',
        quantity: 2,
        reorderAt: 1,
      ),
    ]);
    companies.addAll([
      CompanyAccount(
        name: 'Jiffy Roadside Assistance',
        plan: 'Pro',
        monthlyPrice: 299,
        status: SubscriptionStatus.active,
        users: 8,
        nextBilling: DateTime.now().add(const Duration(days: 24)),
      ),
      CompanyAccount(
        name: 'Speedy Tow Services',
        plan: 'Standard',
        monthlyPrice: 199,
        status: SubscriptionStatus.active,
        users: 5,
        nextBilling: DateTime.now().add(const Duration(days: 26)),
      ),
      CompanyAccount(
        name: 'QuickAssist Roadside',
        plan: 'Basic',
        monthlyPrice: 99,
        status: SubscriptionStatus.pastDue,
        users: 3,
        nextBilling: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CompanyAccount(
        name: 'All Day Roadside',
        plan: 'Standard',
        monthlyPrice: 199,
        status: SubscriptionStatus.suspended,
        users: 2,
        nextBilling: DateTime.now().subtract(const Duration(days: 46)),
      ),
    ]);
    for (final technician in technicians) {
      technician.activeJobs = jobs
          .where(
            (job) =>
                job.technician == technician.name &&
                job.status != JobStatus.completed &&
                job.status != JobStatus.cancelled,
          )
          .length;
      if (technician.activeJobs > 0 &&
          technician.status == TechnicianStatus.available)
        technician.status = TechnicianStatus.busy;
    }
    partnerConnectors.addAll([
      PartnerConnector(
        id: 'PARTNER-TRAXERO',
        name: 'Traxero-Compatible Platform',
        category: PartnerCategory.platform,
        mode: IntegrationMode.api,
        notes: 'Enter approved partner endpoint and credentials when supplied.',
      ),
      PartnerConnector(
        id: 'PARTNER-AGERO',
        name: 'Agero / Swoop',
        category: PartnerCategory.motorClub,
        mode: IntegrationMode.api,
      ),
      PartnerConnector(
        id: 'PARTNER-ALLSTATE',
        name: 'Allstate Roadside',
        category: PartnerCategory.insurance,
        mode: IntegrationMode.webhook,
      ),
      PartnerConnector(
        id: 'PARTNER-HONK',
        name: 'HONK',
        category: PartnerCategory.motorClub,
        mode: IntegrationMode.api,
      ),
      PartnerConnector(
        id: 'PARTNER-NSD',
        name: 'Nation Safe Drivers',
        category: PartnerCategory.motorClub,
        mode: IntegrationMode.email,
      ),
      PartnerConnector(
        id: 'PARTNER-ROADAMERICA',
        name: 'Road America',
        category: PartnerCategory.motorClub,
        mode: IntegrationMode.csv,
      ),
      PartnerConnector(
        id: 'PARTNER-FLEET',
        name: 'Fleet / Dealership Partner',
        category: PartnerCategory.fleet,
        mode: IntegrationMode.manual,
      ),
    ]);
    clubDispatches.add(
      ClubDispatch(
        id: 'MC-9001',
        partner: 'Agero / Swoop',
        referenceNumber: 'SWP-247901',
        purchaseOrder: 'PO-88142',
        customer: 'Sample Motor Club Customer',
        phone: '205-555-0177',
        vehicle: '2021 Chevrolet Equinox',
        service: 'Jump Start',
        pickupAddress: 'Birmingham, AL',
        authorizedAmount: 125,
        authorizedMiles: 10,
      ),
    );
    integrationLogs.add(
      ActivityEntry('Motor Club Integration Hub initialized', 'System'),
    );
    activity.addAll([
      ActivityEntry('Completed job JR-4101', 'Carlos Rivera'),
      ActivityEntry('Created quote for tire replacement', 'Dispatcher'),
      ActivityEntry('Subscription payment received', 'System'),
    ]);
  }

  final jobs = <RoadsideJob>[];
  final customers = <Customer>[];
  final technicians = <Technician>[];
  final inventory = <InventoryItem>[];
  final companies = <CompanyAccount>[];
  final activity = <ActivityEntry>[];
  final partnerConnectors = <PartnerConnector>[];
  final clubDispatches = <ClubDispatch>[];
  final integrationLogs = <ActivityEntry>[];

  void _restore(Map<String, dynamic> data) {
    jobs.addAll(
      ((data['jobs'] as List?) ?? const []).map(
        (e) => RoadsideJob.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    customers.addAll(
      ((data['customers'] as List?) ?? const []).map(
        (e) => Customer.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    technicians.addAll(
      ((data['technicians'] as List?) ?? const []).map(
        (e) => Technician.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    inventory.addAll(
      ((data['inventory'] as List?) ?? const []).map(
        (e) => InventoryItem.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    companies.addAll(
      ((data['companies'] as List?) ?? const []).map(
        (e) => CompanyAccount.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    activity.addAll(
      ((data['activity'] as List?) ?? const []).map(
        (e) => ActivityEntry.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    partnerConnectors.addAll(
      ((data['partnerConnectors'] as List?) ?? const []).map(
        (e) => PartnerConnector.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    clubDispatches.addAll(
      ((data['clubDispatches'] as List?) ?? const []).map(
        (e) => ClubDispatch.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    integrationLogs.addAll(
      ((data['integrationLogs'] as List?) ?? const []).map(
        (e) => ActivityEntry.fromJson(Map<String, dynamic>.from(e)),
      ),
    );
    if (partnerConnectors.isEmpty) {
      partnerConnectors.add(
        PartnerConnector(
          id: 'PARTNER-MANUAL',
          name: 'Manual Partner Import',
          category: PartnerCategory.platform,
        ),
      );
    }
    _recountTechnicians();
  }

  Map<String, dynamic> toJson() => {
    'jobs': jobs.map((e) => e.toJson()).toList(),
    'customers': customers.map((e) => e.toJson()).toList(),
    'technicians': technicians.map((e) => e.toJson()).toList(),
    'inventory': inventory.map((e) => e.toJson()).toList(),
    'companies': companies.map((e) => e.toJson()).toList(),
    'activity': activity.take(500).map((e) => e.toJson()).toList(),
    'partnerConnectors': partnerConnectors.map((e) => e.toJson()).toList(),
    'clubDispatches': clubDispatches.map((e) => e.toJson()).toList(),
    'integrationLogs': integrationLogs
        .take(500)
        .map((e) => e.toJson())
        .toList(),
  };

  Future<void> _persist() => _storage.save(toJson());
  void _changed() {
    notifyListeners();
    _persist();
  }

  void _recountTechnicians() {
    for (final technician in technicians) {
      technician.activeJobs = jobs
          .where(
            (job) =>
                job.technician == technician.name &&
                job.status != JobStatus.completed &&
                job.status != JobStatus.cancelled,
          )
          .length;
    }
  }

  Future<void> resetDemoData() async {
    jobs.clear();
    customers.clear();
    technicians.clear();
    inventory.clear();
    companies.clear();
    activity.clear();
    partnerConnectors.clear();
    clubDispatches.clear();
    integrationLogs.clear();
    _seed();
    _changed();
  }

  Technician? technicianByName(String name) {
    for (final technician in technicians) {
      if (technician.name == name) return technician;
    }
    return null;
  }

  double get revenue => jobs.fold(0, (sum, job) => sum + job.total);
  double get profit => jobs.fold(0, (sum, job) => sum + job.profit);
  double get mrr => companies
      .where((c) => c.status == SubscriptionStatus.active)
      .fold(0, (sum, c) => sum + c.monthlyPrice);
  int get activeJobs => jobs
      .where(
        (j) =>
            j.status != JobStatus.completed && j.status != JobStatus.cancelled,
      )
      .length;

  void addJob(RoadsideJob job) {
    jobs.insert(0, job);
    activity.insert(0, ActivityEntry('Created job ${job.id}', 'Dispatcher'));
    _changed();
  }

  void updateJobStatus(RoadsideJob job, JobStatus status) {
    final wasActive =
        job.status != JobStatus.completed && job.status != JobStatus.cancelled;
    final isActive =
        status != JobStatus.completed && status != JobStatus.cancelled;
    job.status = status;
    final technician = technicianByName(job.technician);
    if (technician != null && wasActive != isActive) {
      technician.activeJobs = (technician.activeJobs + (isActive ? 1 : -1))
          .clamp(0, 999)
          .toInt();
      if (technician.activeJobs == 0 &&
          technician.status == TechnicianStatus.busy)
        technician.status = TechnicianStatus.available;
    }
    activity.insert(
      0,
      ActivityEntry(
        'Changed ${job.id} to ${labelStatus(status)}',
        'Dispatcher',
      ),
    );
    _changed();
  }

  void assignTechnician(RoadsideJob job, String technician) {
    final previous = technicianByName(job.technician);
    final next = technicianByName(technician);
    job.technician = technician;
    if (previous != null && previous.activeJobs > 0) previous.activeJobs--;
    if (next != null) {
      next.activeJobs++;
      if (next.status == TechnicianStatus.available)
        next.status = TechnicianStatus.busy;
    }
    activity.insert(
      0,
      ActivityEntry('Assigned ${job.id} to $technician', 'Dispatcher'),
    );
    _changed();
  }

  void addTechnician(Technician technician) {
    technicians.add(technician);
    activity.insert(
      0,
      ActivityEntry('Added technician ${technician.name}', 'Owner'),
    );
    _changed();
  }

  void updateTechnician(
    Technician technician, {
    required String name,
    required String phone,
    required String area,
    required TechnicianStatus status,
  }) {
    final oldName = technician.name;
    technician.name = name;
    technician.phone = phone;
    technician.area = area;
    technician.status = status;
    if (oldName != name) {
      for (final job in jobs.where((j) => j.technician == oldName)) {
        job.technician = name;
      }
    }
    activity.insert(0, ActivityEntry('Updated technician $name', 'Owner'));
    _changed();
  }

  bool removeTechnician(Technician technician) {
    final assigned = jobs.any(
      (j) =>
          j.technician == technician.name &&
          j.status != JobStatus.completed &&
          j.status != JobStatus.cancelled,
    );
    if (assigned) return false;
    technicians.remove(technician);
    activity.insert(
      0,
      ActivityEntry('Removed technician ${technician.name}', 'Owner'),
    );
    _changed();
    return true;
  }

  void setTechnicianStatus(Technician technician, TechnicianStatus status) {
    technician.status = status;
    activity.insert(
      0,
      ActivityEntry(
        '${technician.name} marked ${labelTechnicianStatus(status)}',
        'Dispatcher',
      ),
    );
    _changed();
  }

  void adjustInventory(InventoryItem item, int delta) {
    item.quantity = (item.quantity + delta).clamp(0, 999).toInt();
    _changed();
  }

  void addClubDispatch(ClubDispatch dispatch) {
    final duplicate = clubDispatches.any(
      (d) =>
          d.partner.toLowerCase() == dispatch.partner.toLowerCase() &&
          d.referenceNumber.toLowerCase() ==
              dispatch.referenceNumber.toLowerCase(),
    );
    if (duplicate) {
      integrationLogs.insert(
        0,
        ActivityEntry(
          'Duplicate dispatch blocked: ${dispatch.partner} ${dispatch.referenceNumber}',
          'System',
        ),
      );
      _changed();
      return;
    }
    clubDispatches.insert(0, dispatch);
    integrationLogs.insert(
      0,
      ActivityEntry(
        'Received dispatch ${dispatch.referenceNumber} from ${dispatch.partner}',
        'Integration Hub',
      ),
    );
    activity.insert(
      0,
      ActivityEntry(
        'New partner dispatch ${dispatch.referenceNumber}',
        'Integration Hub',
      ),
    );
    _changed();
  }

  void updateClubDispatchStatus(
    ClubDispatch dispatch,
    ClubDispatchStatus status,
  ) {
    dispatch.status = status;
    integrationLogs.insert(
      0,
      ActivityEntry(
        '${dispatch.referenceNumber} changed to ${clubDispatchStatusLabel(status)}',
        'Dispatcher',
      ),
    );
    _changed();
  }

  void assignClubDispatch(ClubDispatch dispatch, String technician) {
    dispatch.technician = technician;
    dispatch.status = ClubDispatchStatus.assigned;
    integrationLogs.insert(
      0,
      ActivityEntry(
        '${dispatch.referenceNumber} assigned to $technician',
        'Dispatcher',
      ),
    );
    _changed();
  }

  void savePartnerConnector(PartnerConnector connector, {String? logMessage}) {
    if (!partnerConnectors.contains(connector))
      partnerConnectors.add(connector);
    if (logMessage != null)
      integrationLogs.insert(0, ActivityEntry(logMessage, 'Integration Admin'));
    _changed();
  }

  void toggleSubscription(CompanyAccount company) {
    company.status = company.status == SubscriptionStatus.active
        ? SubscriptionStatus.suspended
        : SubscriptionStatus.active;
    activity.insert(
      0,
      ActivityEntry(
        '${company.name} changed to ${company.status.name}',
        'Super Admin',
      ),
    );
    _changed();
  }
}

String labelStatus(JobStatus status) {
  switch (status) {
    case JobStatus.newJob:
      return 'New';
    case JobStatus.accepted:
      return 'Accepted';
    case JobStatus.enRoute:
      return 'En Route';
    case JobStatus.onSite:
      return 'On Site';
    case JobStatus.inProgress:
      return 'In Progress';
    case JobStatus.completed:
      return 'Completed';
    case JobStatus.cancelled:
      return 'Cancelled';
  }
}

String labelTechnicianStatus(TechnicianStatus status) {
  switch (status) {
    case TechnicianStatus.available:
      return 'Available';
    case TechnicianStatus.busy:
      return 'Busy';
    case TechnicianStatus.offDuty:
      return 'Off Duty';
    case TechnicianStatus.offline:
      return 'Offline';
  }
}
