import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopping_list_sample/controllers/auth_controller.dart';

import '../models/item_model.dart';
import '../repositories/custom_exception.dart';
import '../repositories/item_repository.dart';

final itemListControllerProvider =
    StateNotifierProvider<ItemListController, AsyncValue<List<Item>>>(
  (ref) {
    final user = ref.watch(authControllerProvider);
    return ItemListController(ref.read, user?.uid);
  },
);

final itemListExceptionProvider = StateProvider<CustomException?>((_) => null);

class ItemListController extends StateNotifier<AsyncValue<List<Item>>> {
  ItemListController(this._read, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      retrieveItems();
    }
  }

  final Reader _read;
  final String? _userId;

  Future<void> addItem({required String name, bool obtained = false}) async {
    try {
      final item = Item(name: name, obtained: obtained);
      final itemId = await _read(itemRepositoryProvider).createItem(
        userId: _userId!,
        item: item,
      );
      state.whenData(
        (items) => state = AsyncValue.data(
          items
            ..add(
              item.copyWith(id: itemId),
            ),
        ),
      );
    } on CustomException catch (e) {
      _read(itemListExceptionProvider.notifier).state = e;
    }
  }

  Future<void> deleteItem({required String itemId}) async {
    try {
      await _read(itemRepositoryProvider).deleteItem(
        userId: _userId!,
        itemId: itemId,
      );
      state.whenData(
        (items) => state = AsyncValue.data(
          items..removeWhere((item) => item.id == itemId),
        ),
      );
    } on CustomException catch (e) {
      _read(itemListExceptionProvider.notifier).state = e;
    }
  }

  Future<void> updateItem({required Item updatedItem}) async {
    try {
      await _read(itemRepositoryProvider)
          .updateItem(userId: _userId!, item: updatedItem);
      state.whenData((items) {
        state = AsyncValue.data([
          for (final item in items)
            if (item.id == updatedItem.id) updatedItem else item
        ]);
      });
    } on CustomException catch (e) {
      _read(itemListExceptionProvider.notifier).state = e;
    }
  }

  Future<void> retrieveItems({bool isRefreshing = false}) async {
    if (isRefreshing) state = const AsyncValue.loading();
    try {
      final items =
          await _read(itemRepositoryProvider).retrieveItems(userId: _userId!);
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } on CustomException catch (e) {
      state = AsyncValue.error(e);
    }
  }
}
