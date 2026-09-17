import 'package:hive/hive.dart';

class FirstOpenDatabase {
  static Box? _firstOpenBox;

  Future<Box> getBox() async {
    if (_firstOpenBox != null && _firstOpenBox!.isOpen) return _firstOpenBox!;
    _firstOpenBox = await Hive.openBox('firstOpenBox');
    return _firstOpenBox!;
  }

  Future setFirstOpenState(bool isOpened) async {
    final box = await getBox();
    await box.put(
      'firstOpen',
      isOpened,
    );
  }

  Future<bool> getFirstOpenState() async {
    final box = await getBox();
    final result = box.get('firstOpen');
    return result ?? false;
  }

  Future deleteFirstOpenState(String uuid) async {
    final box = await getBox();
    await box.clear();
  }
}
