import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/core/usecases/app_usecase.dart';
import 'package:everblue/features/items/data/repositories/item_repository.dart';
import 'package:everblue/features/items/domain/repositories/item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadItemPhotoParams extends Equatable {
  final File photo;

  const UploadItemPhotoParams({required this.photo});

  @override
  List<Object?> get props => [photo.path];
}

final uploadItemPhotoUsecaseProvider = Provider<UploadItemPhotoUsecase>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return UploadItemPhotoUsecase(repository: repository);
});

class UploadItemPhotoUsecase
    implements UsecaseWithParms<String, UploadItemPhotoParams> {
  final IItemRepository _repository;

  UploadItemPhotoUsecase({required IItemRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, String>> call(UploadItemPhotoParams params) {
    return _repository.uploadItemPhoto(params.photo);
  }
}
