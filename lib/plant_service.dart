import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grow_life/plant_model.dart';

class PlantService {
  final String baseUrl = 'https://perenual.com/api'; // Update with your API base URL
  final String apiKey = 'sk-mMvU66b3563009df06458';
   // Update with your API key

Future<List<Plant>> fetchPlants(String query) async {
  print('Fetching plants with query: $query'); // Debug statement
  try {
    final response = await http.get(Uri.parse('$baseUrl/species-list?key=$apiKey&q=$query'));
    print('Response status: ${response.statusCode}'); // Debug statement
    print('Response body: ${response.body}'); // Debug statement

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        final plants = (data['data'] as List).map((item) {
          return Plant(
            commonName: item['common_name'] ?? '',
            scientificName: List<String>.from(item['scientific_name'] ?? []),
            imageUrl: item['default_image'] != null ? item['default_image']['regular_url'] : null,
            type: null, // Placeholder, will be updated later
            cycle: '', // Placeholder
            watering: '', // Placeholder
            wateringPeriod: '', // Placeholder
            sunlight: [], // Placeholder
            propagation: [], // Placeholder
            pruningMonth: [], // Placeholder
            seeds: 0, // Placeholder
            flowers: false, // Placeholder
            floweringSeason: null, // Placeholder
            edibleFruit: false, id: item['id'] ?? '', // Placeholder
          );
        }).toList();
         final limitedPlants = plants.take(5).toList();
          print('Found plants: $limitedPlants'); // Debug statement
          return limitedPlants;
      } else {
        print('No data found for the query.'); // Debug statement
      }
    } else {
      print('Error: Response status code is ${response.statusCode}.'); // Debug statement
    }
  } catch (e) {
    print('Exception caught: $e'); // Debug statement
  }
  return [];
}

  Future<Plant> fetchPlantDetails(int id) async {
  print('Fetching plant details for ID: $id'); // Debug statement
  try {
    final response = await http.get(Uri.parse('$baseUrl/species/details/$id?key=$apiKey'));
    print('Response status: ${response.statusCode}'); // Debug statement
    print('Response body: ${response.body}'); // Debug statement

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final plant = Plant.fromJson(data);
      print('Fetched plant details: ${plant.commonName}'); // Debug statement
      return plant;
    } else {
      print('Error: Response status code is ${response.statusCode}.'); // Debug statement
      throw Exception('Failed to load plant details');
    }
  } catch (e) {
    print('Exception caught: $e'); // Debug statement
    throw Exception('Failed to load plant details');
  }
}
}