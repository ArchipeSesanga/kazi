import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/env.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Firebase singletons — per TDD §9.5.
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseStorage>.value(value: FirebaseStorage.instance),
        Provider<FirebaseFunctions>.value(
          value: FirebaseFunctions.instanceFor(region: Env.functionsRegion),
        ),
        // TODO(KZ-002): add services, repositories and global controllers
        //               as each layer is implemented.
      ],
      child: child,
    );
  }
}
