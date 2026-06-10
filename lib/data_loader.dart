import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/scoped-models/user_scope_model.dart';

class DataLoader extends StatefulWidget {
  final Widget child;
  final MainModel model;
  
  const DataLoader({
    Key? key,
    required this.child,
    required this.model,
  }) : super(key: key);

  @override
  _DataLoaderState createState() => _DataLoaderState();
}

class _DataLoaderState extends State<DataLoader> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Load your CompanyUser data here
      await widget.model ; // Implement this in your MainModel
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _hasError = true);
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to load initial data. Please refresh.'),
          ),
        ),
      );
    }

    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return widget.child;
  }
}