import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../data/WorkoutSplit.dart';
import '../data/exercise_list.dart';
import '../data/hive_database.dart';
import '../models/SingleExercise.dart';

class MySplitPage extends StatefulWidget {
  const MySplitPage({super.key});

  @override
  _MySplitPageState createState() => _MySplitPageState();
}

class _MySplitPageState extends State<MySplitPage> {
  List<WorkoutSplit> weeklySplits = [];
  HiveDatabase db = HiveDatabase();

  @override
  void initState() {
    super.initState();
    weeklySplits = db.loadWorkoutSplits(); // Load splits on initialization
  }
  List<String> muscleGroups = [
    'Chest', 'Back', 'Legs', 'Biceps', 'Shoulders', 'Triceps'
  ];
  List<String> selectedMuscleGroups = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workout Split',
        style: TextStyle(
          color: Colors.white,
        ),),

        backgroundColor: Colors.grey[900],
      ),
      body: Container(
        color: Colors.grey[900],
        child: ListView.builder(
          itemCount: weeklySplits.length,
          itemBuilder: (context, index) {
            var muscleGroups = weeklySplits[index].muscleGroups;
            var uniqueMuscleGroupNames = muscleGroups.map((mg) => mg.muscleGroupName).toSet();

            // Remove duplicates by only keeping unique muscle groups based on name
            weeklySplits[index].muscleGroups = muscleGroups
                .where((mg) => uniqueMuscleGroupNames.remove(mg.muscleGroupName))
                .toList();

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  title: Text(weeklySplits[index].day, style: TextStyle(
                    color: Colors.white,
                  ),),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _confirmDelete(index),
                  ),
                  children: weeklySplits[index].muscleGroups.map((mg) => ListTile(
                    title: Text(mg.muscleGroupName, style: TextStyle(
                      color: Colors.white,
                    ),),
                    subtitle: Column(
                      children: mg.exercises.map((exercise) => ListTile(
                        title: Text(exercise.name, style: TextStyle(
                          color: Colors.white,
                        ),),
                        subtitle: Text('${exercise.sets} sets x ${exercise.reps} reps at ${exercise.weight} lbs', style: TextStyle(
                          color: Colors.white,
                        ),),
                      )).toList(),
                    ),
                  )).toList(),
                ),

              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSplit,
        tooltip: 'Add New Split',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this workout day?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog but don't delete
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteWorkoutDay(index); // Proceed with deletion
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  void _deleteWorkoutDay(int index) {
    setState(() {
      weeklySplits.removeAt(index); // Remove the split from the list
    });
    db.saveWorkoutSplits(weeklySplits); // Save the updated list to the database
  }
  void _addNewSplit() {
    String selectedDay = 'Monday'; // Default day
    List<MuscleGroupSplit> muscleGroups = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Ensure this StatefulBuilder is used to update the dialog's state
          builder: (BuildContext context, StateSetter setDialogState) { // This setDialogState is used for updating the dialog
            return AlertDialog(
              title: const Text('Add New Workout Split'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButton<String>(
                      value: selectedDay,
                      onChanged: (String? newValue) {
                        setDialogState(() { // This updates the dialog's state
                          selectedDay = newValue!;
                        });
                      },
                      items: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    ...muscleGroups.map((mg) => ListTile(
                      title: Text(mg.muscleGroupName),
                      subtitle: Text(mg.exercises.map((e) => e.name).join(', ')),
                    )),
                    TextButton(
                      onPressed: () => _addMuscleGroup(muscleGroups),
                      child: const Text('Add Muscle Group'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDay.isNotEmpty) {
                      weeklySplits.add(WorkoutSplit(day: selectedDay, muscleGroups: muscleGroups));
                      db.saveWorkoutSplits(weeklySplits); // Persist data
                      Navigator.pop(context);
                      setState(() {}); // This triggers a rebuild of the widget, refreshing the display
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  void dispose() {
    db.saveWorkoutSplits(weeklySplits); // Save splits when the page is disposed
    super.dispose();
  }
  void _addMuscleGroup(List<MuscleGroupSplit> muscleGroups) {
    List<String> allMuscleGroups = ['Chest', 'Back', 'Legs', 'Biceps','Triceps', 'Shoulders','Abs']; // Example muscle groups
    List<String> selectedMuscleGroupNames = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // This will allow us to update the state inside the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Muscle Group'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          'Select Muscle Groups',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: allMuscleGroups.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            enabled: false,
                            child: StatefulBuilder(
                              builder: (context, menuSetState) {
                                final isSelected = selectedMuscleGroupNames.contains(item);
                                return InkWell(
                                  onTap: () {
                                    isSelected ? selectedMuscleGroupNames.remove(item) : selectedMuscleGroupNames.add(item);
                                    setState(() {}); // State update to refresh dialog
                                    menuSetState(() {});
                                  },
                                  child: Container(
                                    height: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        Icon(isSelected ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                                        const SizedBox(width: 16),
                                        Text(item),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {},
                        selectedItemBuilder: (context) {
                          return allMuscleGroups.map(
                                (item) {
                              return Container(
                                alignment: AlignmentDirectional.center,
                                child: Text(
                                  selectedMuscleGroupNames.join(', '),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              );
                            },
                          ).toList();
                        },
                      ),
                    ),
                    if (selectedMuscleGroupNames.isNotEmpty)
                      Column(
                        children: selectedMuscleGroupNames.map((mg) {
                          return ListTile(
                            title: Text(mg),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                // This could open another dialog to add exercises for this specific muscle group
                                _addExercise(muscleGroups, mg);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    muscleGroups.addAll(selectedMuscleGroupNames.map((name) => MuscleGroupSplit(muscleGroupName: name, exercises: [])));
                    Navigator.pop(context);
                  },
                  child: const Text('Save Muscle Group'),
                ),
              ],
            );
          },
        );
      },
    );
  }




  void _addExercise(List<MuscleGroupSplit> muscleGroups, String muscleGroupName) {
    String exerciseName = '';
    int reps = 0;
    int sets = 0;
    double weight = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Exercise to $muscleGroupName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownSearch<SingleExercise>(
                  popupProps: PopupProps.menu(
                    showSelectedItems: true,
                    showSearchBox: true,
                    itemBuilder: (context, item, isSelected) => ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.muscleGroup),
                    ),
                  ),
                  items: exerciseList,
                  onChanged: (SingleExercise? selectedItem) {
                    if (selectedItem != null) {
                      exerciseName = selectedItem.name;
                     // musclegroupController.text = selectedItem.muscleGroup; // Store muscle group
                    }
                  },
                  itemAsString: (SingleExercise? item) => item?.name ?? '',
                  compareFn: (item1, item2) => item1.name == item2.name && item1.muscleGroup == item2.muscleGroup, // Comparison function
                  selectedItem: SingleExercise(name: "Select an Exercise", muscleGroup: ""),
                ),


                TextField(
                  decoration: const InputDecoration(labelText: 'Sets'),
                  onChanged: (value) => sets = int.parse(value),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Reps'),
                  onChanged: (value) => reps = int.parse(value),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                  onChanged: (value) => weight = double.parse(value),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (exerciseName.isNotEmpty && reps > 0 && sets > 0 && weight > 0) {
                  // Find the muscle group by name and add the new exercise
                  var muscleGroup = muscleGroups.firstWhere(
                          (mg) => mg.muscleGroupName == muscleGroupName,
                      orElse: () => MuscleGroupSplit(muscleGroupName: muscleGroupName, exercises: [])
                  );
                  if (!muscleGroups.contains(muscleGroup)) {
                    muscleGroups.add(muscleGroup);
                  }
                  muscleGroup.exercises.add(ExerciseDetail(name: exerciseName, reps: reps, sets: sets, weight: weight));

                  // Update the UI to reflect the change
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Exercise'),
            ),
          ],
        );
      },
    );
  }

}
