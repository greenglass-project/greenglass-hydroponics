import 'package:flutter/material.dart';
import 'package:hydroponics_panel/screens/installation/menudialog/recipe_list_card.dart';
import 'package:hydroponics_panel/screens/installation/menudialog/recipe_plant_list_card.dart';

class RecipeDialog extends StatefulWidget {
  final String installationId;
  final String systemId;
  const RecipeDialog(this.installationId, this.systemId, {super.key});

  @override
  State<StatefulWidget> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends State<RecipeDialog> {

  String? plantId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        //width: double.infinity,
        height: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 800,
                  height: 600,
                  child: Card(
                      elevation: 0,
                      color: Colors.black,
                      margin: const EdgeInsetsDirectional.only(
                          start: 30.0, end: 30.0),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white)),
                      child: plantId == null ?
                        RecipePlantListCard(widget.systemId, (p) => setState(() => plantId = p)) :
                        RecipeListCard(widget.installationId, widget.systemId, plantId!))
            )]));
  }


}
