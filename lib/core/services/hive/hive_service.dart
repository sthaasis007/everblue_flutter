import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lost_n_found/core/constants/hive_table_constants.dart';
import 'package:lost_n_found/features/auth/data/models/auth_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstants.dbName}';
    Hive.init(path);
    _registerAdapter();
  }
  
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    
  }

  Future<void> openboxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
  }
  
  Future<void> close() async {
    await Hive.close();
  }

  Box<AuthHiveModel> get _authBox =>
    Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
    }

    //Login
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    } 
    return null;
  }  

  //logout
  Future<void> logoutUser() async {
    
  }

  //get current user
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  //check email existence
  bool isEmailExists(String email) {
    final users = _authBox.values.where(
      (user) => user.email == email,
    );
    return users.isNotEmpty;
  }
}