import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NextScreenDetails {
  Function() onClick;
  Widget nextScreen;
  NextScreenDetails({ required this.nextScreen, required this.onClick });
}

class ActionScreenDetails {
  Function() onClick;
  IconData icon;
  Color? iconColor;

  ActionScreenDetails({required this.onClick, required this.icon, this.iconColor = Colors.white54});
}

class IndustrialScreen extends StatefulWidget {

  final Widget body;
  final String name;
  final bool enableBack;
  final ActionScreenDetails? topAction;
  final ActionScreenDetails? bottomLeftAction;
  final ActionScreenDetails? bottomRightAction;

  const IndustrialScreen({
    required this.name,
    required this.body,
    this.enableBack = false,
    this.topAction,
    this.bottomLeftAction,
    this.bottomRightAction,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _IndustrialScreenState();
}

class _IndustrialScreenState extends State<IndustrialScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        body: Padding(
        padding : const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25),
            child:
        Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children : [
          Container(
            color: Colors.transparent,
            //height : 120,
            child : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildHeader()
            )
          ),

          Flexible( child:
              Container(
                width: double.infinity,
                child : widget.body
              )
          ),

          Container(
              color: Colors.transparent,
              height : 100,
              child : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildFooter()
              )
          ),
        ])
    ));
  }

  List<Widget> _buildFooter() {
    List<Widget> widgets = [];
    if(widget.enableBack == true) {
      widgets.add(Container(color: Colors.transparent, width: 100,
          child:
          IconButton(
              iconSize: 56,
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54),
              onPressed: () => Get.back()
          ))
      );
    } else if(widget.bottomLeftAction != null) {
      widgets.add(Container(color: Colors.transparent, width: 100,
          child:
          IconButton(
              iconSize: 56,
              icon: Icon(widget.bottomLeftAction!.icon, color: widget.bottomLeftAction!.iconColor),
              onPressed: () => widget.bottomLeftAction!.onClick()
          ))
      );
    }
    widgets.add(
        Expanded( child :
          Container(color: Colors.transparent,
            alignment: Alignment.center,
          )
        )
    );

    if(widget.bottomRightAction != null) {
      widgets.add(Container(color: Colors.transparent, width: 100,
          child:
          IconButton(
              iconSize: 56,
              icon: Icon(widget.bottomRightAction!.icon, color: widget.bottomRightAction!.iconColor,),
              onPressed: () => widget.bottomRightAction!.onClick()
          ))
      );
    }
    return widgets;
  }


  List<Widget> _buildHeader() {
    List<Widget> widgets = [];

    widgets.add(Expanded( child :
      Container(color: Colors.transparent,
          alignment: Alignment.centerLeft,
          child : Padding(
              padding : const EdgeInsets.fromLTRB(50,0,0,0),
              child: Text(
                widget.name,
                style: Theme.of(context).textTheme.titleLarge
              )
          )
      ))
    );

    if(widget.topAction != null) {
      widgets.add(Container(color: Colors.transparent, width: 100,
          child: IconButton(
              iconSize: 56,
              icon: Icon(widget.topAction!.icon, color: Colors.white54,),
              onPressed: () => {widget.topAction!.onClick()}
          )),
      );
    }
    return widgets;
  }
}
