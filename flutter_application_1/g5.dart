import 'package:flutter/material.dart';

class Car {
  final String id;
  final String make;
  final String model;
  final int year;
  final String imageUrl;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.imageUrl,
  });
}

class CarService {
  final List<Car> _cars = [
    Car(
      id: '1',
      make: 'Toyota',
      model: 'Corolla',
      year: 2020,
      imageUrl: 'https://example.com/toyota-corolla.jpg',
    ),
    Car(
      id: '2',
      make: 'Honda',
      model: 'Civic',
      year: 2021,
      imageUrl: 'https://example.com/honda-civic.jpg',
    ),
    Car(
      id: '3',
      make: 'Ford',
      model: 'Mustang',
      year: 2019,
      imageUrl: 'https://example.com/ford-mustang.jpg',
    ),
  ];

  Future<List<Car>> fetchCars() async {
    return _cars;
  }

  Future<void> addCar(Car car) async {
    _cars.add(car);
  }

  Future<void> updateCar(Car car) async {
    final index = _cars.indexWhere((c) => c.id == car.id);
    if (index != -1) {
      _cars[index] = car;
    }
  }

  Future<void> deleteCar(String id) async {
    _cars.removeWhere((c) => c.id == id);
  }
}

class CarRentalPage extends StatefulWidget {
  @override
  _CarRentalPageState createState() => _CarRentalPageState();
}

class _CarRentalPageState extends State<CarRentalPage> {
  final _carService = CarService();
  late Future<List<Car>> _carsFuture;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _carsFuture = _carService.fetchCars();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Rental'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a car',
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Car>>(
              future: _carsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final filteredCars = snapshot.data!
                      .where((car) => car.model
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .toList();
                  return ListView.builder(
                    itemCount: filteredCars.length,
                    itemBuilder: (context, index) {
                      final car = filteredCars[index];
                      return ListTile(
                        leading: Image.network(car.imageUrl, width: 50),
                        title: Text('${car.year} ${car.make} ${car.model}'),
                        subtitle: Text('ID: ${car.id}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Navigate to the update screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateCarPage(car: car),
                                  ),
                                ).then((result) {
                                  if (result == true) {
                                    setState(() {
                                      _carsFuture = _carService.fetchCars();
                                    });
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                // Handle delete action
                                await _carService.deleteCar(car.id);
                                setState(() {
                                  _carsFuture = _carService.fetchCars();
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCarPage(),
            ),
          ).then((result) {
            if (result == true) {
              setState(() {
                _carsFuture = _carService.fetchCars();
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddCarPage extends StatelessWidget {
  final _carService = CarService();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _makeController,
              decoration: InputDecoration(labelText: 'Make'),
            ),
            TextField(
              controller: _modelController,
              decoration: InputDecoration(labelText: 'Model'),
            ),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Validate input
                if (_makeController.text.isEmpty ||
                    _modelController.text.isEmpty ||
                    _yearController.text.isEmpty ||
                    _imageUrlController.text.isEmpty) {
                  // Display an error message or show a Snackbar
                  return;
                }

                // Create a new car object
                final newCar = Car(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  make: _makeController.text,
                  model: _modelController.text,
                  year: int.parse(_yearController.text),
                  imageUrl: _imageUrlController.text,
                );

                // Add the new car to the list
                await _carService.addCar(newCar);

                // Close the add screen and return to the main screen
                Navigator.pop(context, true);
              },
              child: Text('Add Car'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateCarPage extends StatefulWidget {
  final CarService carService;
  final Car car;

  UpdateCarPage({required this.carService, required this.car});

  @override
  _UpdateCarPageState createState() => _UpdateCarPageState();
}

class _UpdateCarPageState extends State<UpdateCarPage> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _makeController.text = widget.car.make;
    _modelController.text = widget.car.model;
    _yearController.text = widget.car.year.toString();
    _imageUrlController.text = widget.car.imageUrl;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _makeController,
              decoration: InputDecoration(labelText: 'Make'),
            ),
            TextField(
              controller: _modelController,
              decoration: InputDecoration(labelText: 'Model'),
            ),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Validate input
                if (_makeController.text.isEmpty ||
                    _modelController.text.isEmpty ||
                    _yearController.text.isEmpty ||
                    _imageUrlController.text.isEmpty) {
                  // Display an error message or show a Snackbar
                  return;
                }

                // Update the car object
                final updatedCar = Car(
                  id: widget.car.id,
                  make: _makeController.text,
                  model: _modelController.text,
                  year: int.parse(_yearController.text),
                  imageUrl: _imageUrlController.text,
                );

                // Update the car in the list
                await widget.carService.updateCar(updatedCar);

                // Close the update screen and return to the main screen
                Navigator.pop(context, true);
              },
              child: Text('Update Car'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CarRentalPage(),
  ));
}
