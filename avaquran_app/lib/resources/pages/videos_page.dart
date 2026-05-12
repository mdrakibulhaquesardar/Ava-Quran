import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class VideosPage extends NyStatefulWidget {

  static RouteView path = ("/videos", (_) => VideosPage());
  
  VideosPage({super.key}) : super(child: () => _VideosPageState());
}

class _VideosPageState extends NyPage<VideosPage> {

  @override
  get init => () {

  };
  
  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Videos")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}
