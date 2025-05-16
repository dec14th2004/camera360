import 'package:app_core/data/mappers/data_mapper.dart';
import 'package:app_util/helpers/parse_util.dart';

import '../../domain/entities/uploaded_panorama.dart';

class PostImagePanoramaModel extends DataMapper<UploadedPanorama> {
  String id;
  String entityId;
  String fileName;
  String fileUrl;

  PostImagePanoramaModel({required this.id, required this.entityId, required this.fileName, required this.fileUrl});

  PostImagePanoramaModel.fromJson(Map<String, dynamic> json)
      : id = parseString(json['id']),
        entityId = parseString(json['entityId']),
        fileName = parseString(json['fileName']),
        fileUrl = parseString(json['fileUrl']);
  @override
  UploadedPanorama mapToEntity() {
    return UploadedPanorama(id: id, entityId: entityId, fileName: fileName, fileUrl: fileUrl);
  }
}