// import 'dart:async';
// import 'dart:developer';
// import 'package:bonsoir/bonsoir.dart';

// class MdnsDiscoveryService {
//   final String serviceType;
//   final StreamController<DiscoveredService> _discoveredStreamController =
//       StreamController.broadcast();
//   final StreamController<DiscoveredService> _deviceOfflineStreamController =
//       StreamController.broadcast();

//   final Set<String> _discoveredHosts = {}; // prevent duplicates
//   BonsoirDiscovery? _discovery;
//   StreamSubscription? _eventSub;

//   MdnsDiscoveryService({this.serviceType = '_http._tcp'});

//   Stream<DiscoveredService> get discoveredServices =>
//       _discoveredStreamController.stream;

//   Stream<DiscoveredService> get deviceOffline =>
//       _deviceOfflineStreamController.stream;

//   // Future<void> startDiscovery() async {
//   //   // Ensure previous discovery is stopped & cleaned up
//   //   await stopDiscovery();

//   //   _discovery = BonsoirDiscovery(type: serviceType);
//   //   await _discovery!.initialize();

//   //   _eventSub = _discovery!.eventStream!.listen((event) {
//   //     if (event is BonsoirDiscoveryServiceFoundEvent) {
//   //       // Automatically resolve when found
//   //       event.service.resolve(_discovery!.serviceResolver);
//   //     }

//   //     if (event is BonsoirDiscoveryServiceResolvedEvent ||
//   //         event is BonsoirDiscoveryServiceUpdatedEvent) {
//   //       final service = event.service;
//   //       final id = '${service?.host}:${service?.port}';

//   //       if (!_discoveredHosts.contains(id)) {
//   //         _discoveredHosts.add(id);

//   //         final discovered = DiscoveredService(
//   //           name: service?.name ?? '',
//   //           host: service?.host ?? '',
//   //           port: service?.port ?? 0,
//   //           ip: service?.host ?? service?.host ?? '',
//   //         );

//   //         _discoveredStreamController.add(discovered);
//   //         log('[mDNS] Discovered: $discovered');
//   //       }
//   //     }

//   //     if (event is BonsoirDiscoveryServiceLostEvent) {
//   //       final service = event.service;
//   //       final id = '${service.host}:${service.port}';
//   //       _discoveredHosts.remove(id);
//   //       final removed = DiscoveredService(
//   //         name: service.name,
//   //         host: service.host ?? '',
//   //         port: service.port,
//   //         ip: service.host ?? service.host ?? '',
//   //       );

//   //       _deviceOfflineStreamController.add(removed);
//   //       log('[mDNS] Service lost: ${service.toJson()}');
//   //     }

//   //     log('Event type: $event');
//   //   });

//   //   await _discovery!.start();
//   // }

//   Future<void> startDiscovery() async {
//   print('🧹 [mDNS] Clearing previous discovery cache...');
//   _discoveredHosts.clear(); // IMPORTANT: Clear the set so it can find the same IP again

//   await stopDiscovery(); // Ensure old listeners are dead

//   _discovery = BonsoirDiscovery(type: serviceType);
//   await _discovery!.initialize();

//   _eventSub = _discovery!.eventStream!.listen((event) {
//     // 1. If we find it, resolve it immediately
//     if (event is BonsoirDiscoveryServiceFoundEvent) {
//       print('🔎 [mDNS] Found ${event.service.name}. Resolving...');
//       event.service.resolve(_discovery!.serviceResolver);
//     }

//     // 2. We use Resolved OR Updated to capture the device
//     if (event is BonsoirDiscoveryServiceResolvedEvent ||
//         event is BonsoirDiscoveryServiceUpdatedEvent) {

//       final service = event.service;
//       if (service == null || service.host == null) return;

//       final id = '${service.host}:${service.port}';

//       // Even if we've seen this ID before, let's update it
//       // in case the app was reloaded
//       final discovered = DiscoveredService(
//         name: service.name,
//         host: service.host!,
//         port: service.port,
//         ip: service.host!,
//       );

//       _discoveredHosts.add(id);
//       _discoveredStreamController.add(discovered);
//       log('[mDNS] Discovered and Streamed: $discovered');
//     }
//   });

//   await _discovery!.start();
// }

//   Future<void> stopDiscovery() async {
//     await _eventSub?.cancel();
//     _eventSub = null;

//     if (_discovery != null) {
//       await _discovery!.stop();
//       _discovery = null;
//     }

//     _discoveredHosts.clear();
//   }

//   /// Only call this when you’re really done with the service
//   Future<void> dispose() async {
//     await stopDiscovery();
//     await _discoveredStreamController.close();
//     await _deviceOfflineStreamController.close();
//   }
// }
import 'dart:async';
import 'dart:developer';
import 'package:bonsoir/bonsoir.dart';

class MdnsDiscoveryService {
  final String serviceType;
  final StreamController<DiscoveredService> _discoveredStreamController =
      StreamController.broadcast();
  final Set<String> _discoveredHosts = {};
  BonsoirDiscovery? _discovery;
  StreamSubscription? _eventSub;

  MdnsDiscoveryService({this.serviceType = '_http._tcp'});

  Stream<DiscoveredService> get discoveredServices =>
      _discoveredStreamController.stream;

  Future<void> startDiscovery() async {
    log('🧹 [mDNS] Restarting discovery for $serviceType...');
    _discoveredHosts.clear();
    await stopDiscovery();

    _discovery = BonsoirDiscovery(type: serviceType);
    await _discovery!.initialize();

    _eventSub = _discovery!.eventStream!.listen((event) {
      Future.microtask(() => _handleDiscoveryEvent(event));
    });

    await _discovery!.start();
  }

  void _handleDiscoveryEvent(BonsoirDiscoveryEvent event) {
    if (event is BonsoirDiscoveryServiceFoundEvent) {
      event.service.resolve(_discovery!.serviceResolver);
    } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
      final service = event.service;
      if (service.host == null) return;

      final id = '${service.host}:${service.port}';
      if (!_discoveredHosts.contains(id)) {
        _discoveredHosts.add(id);
        _discoveredStreamController.add(DiscoveredService(
          name: service.name,
          ip: service.host!,
          port: service.port, host: service.host!, // This will be 80
        ));
      }
    }
  }

  Future<void> stopDiscovery() async {
    await _eventSub?.cancel();
    if (_discovery != null) {
      await _discovery!.stop();
      _discovery = null;
    }
  }
}

class DiscoveredService {
  final String name;
  final String host;
  final int port;
  final String ip;
  DateTime lastSeen;

  DiscoveredService({
    required this.name,
    required this.host,
    required this.port,
    required this.ip,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredService &&
          runtimeType == other.runtimeType &&
          ip == other.ip &&
          port == other.port &&
          name == other.name;

  @override
  int get hashCode => ip.hashCode ^ port.hashCode;

  @override
  String toString() =>
      'DiscoveredService{name: $name, host: $host, port: $port, ip: $ip}';
}
