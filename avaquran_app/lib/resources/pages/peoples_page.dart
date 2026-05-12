import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PeoplesPage extends NyStatefulWidget {

  static RouteView path = ("/peoples", (_) => PeoplesPage());
  
  PeoplesPage({super.key}) : super(child: () => _PeoplesPageState());
}

class _PeoplesPageState extends NyPage<PeoplesPage> {

  @override
  get init => () {

  };
  
  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Peoples")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}
