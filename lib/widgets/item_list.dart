import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopping_list_sample/controllers/item_list_controller.dart';
import 'package:shopping_list_sample/widgets/add_item_dialog.dart';

import '../repositories/custom_exception.dart';

class ItemList extends HookConsumerWidget {
  const ItemList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemList = ref.watch(itemListControllerProvider);
    return itemList.when(
      data: (items) => items.isEmpty
          ? const Center(
              child: Text(
                'Tap + to add an item',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return ListTile(
                  key: ValueKey(item.id),
                  title: Text(item.name),
                  trailing: Checkbox(
                    value: item.obtained,
                    onChanged: (val) => ref
                        .read(itemListControllerProvider.notifier)
                        .updateItem(
                          updatedItem: item.copyWith(obtained: !item.obtained),
                        ),
                  ),
                  onTap: () => AddItemDialog.show(context, item),
                  onLongPress: () => ref
                      .read(itemListControllerProvider.notifier)
                      .deleteItem(itemId: item.id!),
                );
              },
            ),
      error: (error, _) => ItemListError(
        message:
            error is CustomException ? error.message! : 'Something went wrong!',
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class ItemListError extends ConsumerWidget {
  final String message;

  const ItemListError({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(fontSize: 20.0)),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () => ref
                .read(itemListControllerProvider.notifier)
                .retrieveItems(isRefreshing: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
