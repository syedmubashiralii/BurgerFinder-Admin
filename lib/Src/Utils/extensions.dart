// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';

extension CustomSpacing on num {
  SizedBox get SpaceX {
    return SizedBox(height: toDouble());
  }

  SizedBox get SpaceY {
    return SizedBox(width: toDouble());
  }
}