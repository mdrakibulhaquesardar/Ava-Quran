import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BlogsPage extends NyStatefulWidget {

  static RouteView path = ("/blogs", (_) => BlogsPage());
  
  BlogsPage({super.key}) : super(child: () => _BlogsPageState());
}

class _BlogsPageState extends NyPage<BlogsPage> {

  @override
  get init => () {

  };
  
  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blogs")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}
