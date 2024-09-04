import 'package:flutter/material.dart';
import 'package:gymapp/components/exercise_tile.dart';
import 'package:gymapp/data/workout_data.dart';
import 'package:provider/provider.dart';
class WorkoutPage extends StatefulWidget{
  final String workoutName;
  const WorkoutPage({super.key, required this.workoutName});
  @override
  State<WorkoutPage> createState() => _MyWidgetState();
}
  class _MyWidgetState extends State<WorkoutPage>{


  //text controllers
    final exerciseNameController = TextEditingController();
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final setsController = TextEditingController();
    final musclegroupController = TextEditingController();
  //create a new exercise
    void createNewExercise(){
      showDialog(
          context: context,
          builder: (context)=> AlertDialog(
            title: Text('Add a new exercise'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //exercise name
                TextField(
                  controller: exerciseNameController,
                ),

                //sets
                TextField(
                  controller: setsController,
                ),

                //reps
                TextField(
                  controller: repsController,
                ),

                //weight
                TextField(
                  controller: weightController,
                ),


              ],
            ),
            actions: [
              //save button
              MaterialButton(
                onPressed: save,
                child: Text ("save"),
              ),
              //cancel button

              MaterialButton(
                onPressed: cancel,
                child: Text ("cancel"),
              ),
            ],
          )
      );
    }
    // save workout
    void save() {
      // get exercise name from text controller
      String newExerciseName = exerciseNameController.text;
      String weight = weightController.text;
      String reps = repsController.text;
      String sets = setsController.text;
      String musclegroup = musclegroupController.text;
      // add exercise to workout
      Provider.of<WorkoutData>(context,listen: false).addExercise(
          widget.workoutName,
          newExerciseName,
          weight,
          reps,
          sets,
          musclegroup,);

      //pop dialog box
      Navigator.pop(context);
      clear();
    }

    //cancel
    void cancel() {
      //pop diolog box
      Navigator.pop(context);
      clear();
    }

    //clear controllers
    void clear(){
      exerciseNameController.clear();
      repsController.clear();
      weightController.clear();
      setsController.clear();
      musclegroupController.clear();
    }
    @override
    Widget build (BuildContext context){
    return Consumer<WorkoutData>(
        builder: (context,value, child) => Scaffold(
          appBar: AppBar(title: Text(widget.workoutName),),
          floatingActionButton: FloatingActionButton(
              onPressed:createNewExercise,
            child: const Icon(Icons.add),
          ),
          body: ListView.builder(
            itemCount: value.numberofExercisesInWorkout(widget.workoutName),
              itemBuilder: (context,index)=> ExerciseTile(
                  exerciseName: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .name,
                  weight: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .weight,
                  reps: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .reps,
                  sets: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .sets,

                  isCompleted: value
                      .getRelevantWorkout(widget.workoutName)
                      .exercises[index]
                      .isCompleted
              ),
          ),
        ),
    );
    }
  }