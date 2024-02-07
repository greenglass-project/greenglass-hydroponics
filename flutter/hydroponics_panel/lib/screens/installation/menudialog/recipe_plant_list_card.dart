import 'package:flutter/material.dart';
import 'package:hydroponics_framework/components/stream_image_menu_card.dart';
import 'package:hydroponics_framework/datamodels/recipes/system_recipes_view_model.dart';
import 'package:hydroponics_framework/mixins/recipe/system_recipes_list_mixin.dart';

class RecipePlantListCard extends StatefulWidget {
  final String systemId;
  final Function(String) onSelect;

  const RecipePlantListCard(this.systemId, this.onSelect, {super.key});

  @override
  State<StatefulWidget> createState() => _RecipePlantListCardState();
}

class _RecipePlantListCardState extends State<RecipePlantListCard>
    with SystemRecipesListMixin {
  @override
  void initState() {
    systemId = widget.systemId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Spacer(),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(
                  'Select plant',
                  style: Theme.of(context).textTheme.titleMedium,
                )),
            const Spacer(),
          ]),
          Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 9, 15, 0),
                      child: GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(10),
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 20,
                      crossAxisCount: 3,
                      childAspectRatio: 1 / 0.85,
                      children: recipes.map((r) => _plantEntry(r)).toList())))
        ]);
  }

  Widget _plantEntry(SystemRecipesViewModel recipe) {
    return StreamImageMenuCard(
      label: recipe.name,
      imageTopic: "findone.plants.${recipe.plantId}.image",
      borderColour: Colors.green,
      margin: 10.0,
      onTap: () => widget.onSelect(recipe.plantId),
    );
  }
}
