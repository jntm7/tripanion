import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/saved_item.dart';

class SavedItemsProvider extends ChangeNotifier {
  static const String _savedItemsKey = 'saved_items';
  List<SavedItem> _savedItems = [];

  List<SavedItem> get savedItems => _savedItems;

  // get saved items by type
  List<SavedItem> getItemsByType(SavedItemType type) {
    return _savedItems.where((item) => item.type == type).toList();
  }

  // check if an item is saved
  bool isSaved(String id) {
    return _savedItems.any((item) => item.id == id);
  }

  SavedItemsProvider() {
    _loadSavedItems();
  }

  // load saved items from preferences
  Future<void> _loadSavedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedItemsJson = prefs.getString(_savedItemsKey);

      if (savedItemsJson != null) {
        final List<dynamic> decoded = json.decode(savedItemsJson);
        _savedItems = decoded.map((item) => SavedItem.fromJson(item)).toList();
        // Sort by saved date (most recent first)
        _savedItems.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved items: $e');
    }
  }

  // persist saved items to preferences
  Future<void> _persistSavedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _savedItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_savedItemsKey, encoded);
    } catch (e) {
      print('Error saving items: $e');
    }
  }

  // add or remove saved item
  Future<void> toggleSavedItem(SavedItem item) async {
    final index = _savedItems.indexWhere((i) => i.id == item.id);

    if (index >= 0) {
      // if item exists => remove it
      _savedItems.removeAt(index);
    } else {
      // if item doesn't exist => add it to index 0
      _savedItems.insert(0, item);
    }

    notifyListeners();
    await _persistSavedItems();
  }

  // add a saved item
  Future<void> addSavedItem(SavedItem item) async {
    if (!isSaved(item.id)) {
      _savedItems.insert(0, item);
      notifyListeners();
      await _persistSavedItems();
    }
  }

  // remove a saved item
  Future<void> removeSavedItem(String id) async {
    _savedItems.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persistSavedItems();
  }

  // clear all saved items
  Future<void> clearAllSavedItems() async {
    _savedItems.clear();
    notifyListeners();
    await _persistSavedItems();
  }

  // clear saved items by type
  Future<void> clearByType(SavedItemType type) async {
    _savedItems.removeWhere((item) => item.type == type);
    notifyListeners();
    await _persistSavedItems();
  }
}
