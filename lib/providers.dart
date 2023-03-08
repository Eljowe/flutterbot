import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidebot/services/kideService.dart';

final generalEventsProvider = StateProvider<List<generalEvent>?>((ref) => null);
