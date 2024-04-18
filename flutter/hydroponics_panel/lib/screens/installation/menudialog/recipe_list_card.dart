import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hydroponics_framework/datamodels/recipes/recipe_view_model.dart';
import 'package:hydroponics_framework/mixins/error/error_dialog_mixin.dart';
import 'package:hydroponics_framework/mixins/recipe/recipe_list_mixin.dart';
import 'package:hydroponics_framework/mixins/installation/new_job_mixin.dart';

class RecipeListCard extends StatefulWidget {
  final String installationId;
  final String systemId;
  final String plantId;
  //final Function(String) onSelect;

  const RecipeListCard(this.installationId, this.systemId, this.plantId, {super.key});

  @override
  State<StatefulWidget> createState() => _RecipeListCardState();
}

class _RecipeListCardState extends State<RecipeListCard> with RecipeListMixin, NewJobMixin, ErrorDialogMixin {

  @override
  void initState() {
    systemId = widget.systemId;
    plantId = widget.plantId;

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
            children : [
              Row(children: [
                const Spacer(),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Text(
                      'Select recipe',
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
                const Spacer(),
              ]),
              Expanded( child: Padding( padding : const EdgeInsets.fromLTRB(20, 30, 20, 30),
                child: ListView( children : _createlist(context)
              ))
            )
    ]);
  }

  List<Widget> _createlist(BuildContext context) {
    List<Widget> list = [];
    for (RecipeViewModel r in recipes.values) {
      list.add(Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10.0),
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white70,
                    width: 1.0,
                    style: BorderStyle.solid),
              ),
              child: InkWell(
                  onTap: () => newJob(widget.installationId, r.recipeId,
                          (job) => Get.back(),
                          (c,m) => displayError(context, c,m)),
                  child: ListTile(
              title: Text(r.description,
                  style: Theme.of(context).textTheme.labelMedium
              ),
              minVerticalPadding: 15.0
          )
          ))));
    }
    return list;
  }
}