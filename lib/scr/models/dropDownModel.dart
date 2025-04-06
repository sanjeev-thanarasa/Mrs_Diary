import 'package:flutter/material.dart';

class DropListModel {
  DropListModel(this.listOptionItems);

  final List<OptionItem> listOptionItems;
}

class OptionItem {
  final String name;

  OptionItem({@required this.name});
}

DropListModel dishDropListModel = DropListModel([
  OptionItem(name: 'sun'),
  OptionItem(name:  'dish tv'),
  OptionItem(name: 'videocon'),
  OptionItem(name: 'airtel'),
  OptionItem(name:  'dialog'),
  OptionItem(name: 'tata sky')]);

OptionItem optionDishSelected = OptionItem(name: "Select Dish Type");

DropListModel villageDropListModel = DropListModel([
  //OptionItem(name: 'நிலாவெளி'),

]);