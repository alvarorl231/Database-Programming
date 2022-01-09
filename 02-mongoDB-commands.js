/*USEFUL COMMANDS:*/
/*MONGO DB*/

use mapreduce // Select the database.

//In this part will be explained the use of 'mapReduce' function.
db.example1.find()

// Example: We need to calculate how many persons there are for each age.
    // First. 'mapFunction', this fuction has an 'emit()' statement. This would be the records that we want to pass to the 'mapReduce' function
    var mapFunction = function() {
        emit(this.age, 1);
    };
    
    // Second. 'reduceFunction', this functions will tell to 'mapReduce' how to procede with the values. 
        // In this case, they will be returned as an array of sumed values.
    var reduceFunction = function(key, values) {
        return Array.sum(values);
    };
    
    // Third. Use 'mapReduce' function. It will create a new collection in the database with the specified name.
    db.example1.mapReduce(mapFunction, reduceFunction, { out: "map_reduce_1" })
    
    // Return all records from 'map_reduce_1'
    db.map_reduce_1.find({}).sort({_id: -1})
    db.map_reduce_1.aggregate([{$sort: {_id: -1}},{$project: {_id: 0, Age: "$_id", "Number of people": "$value"}}])

