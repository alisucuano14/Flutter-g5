import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Car {
  final String name;
  final String model;
  final double price;
  bool isRented;

  Car({required this.name, required this.model, required this.price, this.isRented = false});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Rental App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CarRentalScreen(),
    );
  }
}

class CarRentalScreen extends StatefulWidget {
  @override
  _CarRentalScreenState createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen> {
  List<Car> cars = [
    Car(name: 'Toyota', model: 'Camry', price: 50.0),
    Car(name: 'Honda', model: 'Accord', price: 55.0),
    Car(name: 'Ford', model: 'Mustang', price: 70.0),
    // Add more cars as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Rental App'),
      ),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${cars[index].name} ${cars[index].model}'),
            subtitle: Text('\$${cars[index].price.toStringAsFixed(2)} per day'),
            trailing: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (!cars[index].isRented) {
                    // If the car is not rented, mark it as rented
                    cars[index].isRented = true;
                    // You can add more logic here, e.g., add to the user's rented cars list
                    // or show a confirmation message.
                  } else {
                    // If the car is already rented, you can add logic to handle this case.
                  }
                });
              },
              child: Text(cars[index].isRented ? 'Rented' : 'Rent'),
            ),
          );
        },
      ),
    );
  }
}
