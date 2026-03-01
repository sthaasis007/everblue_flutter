import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:everblue/core/error/failures.dart';
import 'package:everblue/features/auth/domain/repositories/auth_repositories.dart';
import 'package:everblue/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockFile extends Mock implements File {}

void main() {
  late UploadPhotoUsecase uploadPhotoUsecase;
  late MockAuthRepository mockAuthRepository;
  late MockFile mockFile;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    uploadPhotoUsecase = UploadPhotoUsecase(authRepository: mockAuthRepository);
    mockFile = MockFile();
  });

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  const tImageUrl = 'https://example.com/image.jpg';

  group('UploadPhotoUsecase', () {
    test('should return image URL when upload is successful', () async {
      // Arrange
      when(() => mockAuthRepository.uploadImage(any()))
          .thenAnswer((_) async => const Right(tImageUrl));

      // Act
      final result = await uploadPhotoUsecase(mockFile);

      // Assert
      expect(result, const Right(tImageUrl));
      verify(() => mockAuthRepository.uploadImage(any()));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when upload fails', () async {
      // Arrange
      const tFailure = ApiFailure(message: 'Upload failed');
      when(() => mockAuthRepository.uploadImage(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await uploadPhotoUsecase(mockFile);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.uploadImage(any()));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
