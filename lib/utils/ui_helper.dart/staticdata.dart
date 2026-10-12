import 'package:ap_dongle_comm/utils/enums/protocol.dart';

class EcuDataSet {
  int? ecuID;
  String? ecuName;
  String? chasisId;
  int? dtcDatasetId;
  int? pidDatasetId;
  int? ivnPidDatasetId;
  int? ivnDtcDatasetId;
  String? clearDtcIndex;
  String? readDtcIndex;
  String? writePidIndex;
  String? iorTestFnIndex;
  String? seedKeyIndex;
  String? txHeader;
  String? rxHeader;
  Protocol? protocol;
  String? channelId;
  String? modelName;
  String? submodelName;
  String? modelYear;
  Enum? ecu2;
  int? ffSet;
  String? firingSequence;
  int? noOfInjectors;

  EcuDataSet({
    this.ecuID,
    this.ecuName,
    this.chasisId,
    this.dtcDatasetId,
    this.pidDatasetId,
    this.ivnPidDatasetId,
    this.ivnDtcDatasetId,
    this.clearDtcIndex,
    this.readDtcIndex,
    this.writePidIndex,
    this.iorTestFnIndex,
    this.seedKeyIndex,
    this.txHeader,
    this.rxHeader,
    this.protocol,
    this.channelId,
    this.modelName,
    this.submodelName,
    this.modelYear,
    this.ecu2,
    this.ffSet,
    this.firingSequence,
    this.noOfInjectors,
  });

  // Example factory for JSON (important for Flutter)
  factory EcuDataSet.fromJson(Map<String, dynamic> json) {
    return EcuDataSet(
      ecuID: json['ecu_ID'],
      ecuName: json['ecu_name'],
      txHeader: json['tx_header'],
      rxHeader: json['rx_header'],
      // protocol: Protocol.fromJson(json['protocol']), // Assuming Protocol has fromJson
    );
  }
}